terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

############################
# VPC
############################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

############################
# SECURITY GROUP
############################

resource "aws_security_group" "main" {
  name   = "${var.project_name}-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group_rule" "mysql_internal" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.main.id
  source_security_group_id = aws_security_group.main.id
}

############################
# ECR
############################

resource "aws_ecr_repository" "backend" {
  name         = "${var.project_name}-backend"
  force_delete = true
}

resource "aws_ecr_repository" "frontend" {
  name         = "${var.project_name}-frontend"
  force_delete = true
}

############################
# EC2 MYSQL
############################

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = var.key_pair_name

  # 🔹 Aumenta disco (clave)
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
    #!/bin/bash

    yum update -y
    yum install -y docker

    systemctl start docker
    systemctl enable docker

    # Esperar a que Docker esté realmente listo
    until docker info > /dev/null 2>&1; do
      echo "Esperando Docker..."
      sleep 3
    done

    # Limpiar espacio por si acaso
    docker system prune -af

    # Levantar MySQL optimizado
    docker run -d \
    --name mysql \
    -e MYSQL_ROOT_PASSWORD=root \
    -e MYSQL_DATABASE=asistencia_db \
    -e MYSQL_ROOT_HOST=% \
    -p 3306:3306 \
    --log-opt max-size=10m \
    --log-opt max-file=3 \
    mysql:8-oracle \
    --bind-address=0.0.0.0 \
    --performance-schema=OFF
  EOF

  tags = {
    Name = "${var.project_name}-mysql"
  }
}

#CLOUD WATCH
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

############################
# ECS
############################

resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

data "aws_iam_role" "lab" {
  name = "LabRole"
}

############################
# TASK APP (frontend + backend)
############################

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = data.aws_iam_role.lab.arn

  container_definitions = jsonencode([

    {
      name  = "backend"
      image = "${aws_ecr_repository.backend.repository_url}:latest"

      portMappings = [
        {
          containerPort = 8080
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/actuator/health/readiness || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 5
        startPeriod = 120
      }

      environment = [
        {
            name  = "DB_HOST",
            value = aws_instance.db.private_ip
        },
        {
            name  = "SPRING_DATASOURCE_URL"
            value = "jdbc:mysql://${aws_instance.db.private_ip}:3306/asistencia_db"
        },
        {
            name  = "SPRING_DATASOURCE_USERNAME"
            value = "root"
        },
        {
            name  = "SPRING_DATASOURCE_PASSWORD"
            value = "root"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "backend"
        }
      }
    },

    {
      name  = "frontend"
      image = "${aws_ecr_repository.frontend.repository_url}:latest"

      portMappings = [
        {
          containerPort = 80
        }
      ]

      dependsOn = [
        {
          containerName = "backend",
          condition = "START"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "frontend"
        }
      }
    }

  ])
}

############################
# SERVICE
############################

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  force_new_deployment = true

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.main.id]
    assign_public_ip = true
  }
}