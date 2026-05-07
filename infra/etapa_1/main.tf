terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#Vamos a crear el ECR: 2 repositorios
resource "aws_ecr_repository" "backend" {
  name = "${var.nombre_proyecto}-backend"
  force_delete = true
}
resource "aws_ecr_repository" "frontend" {
  name = "${var.nombre_proyecto}-frontend"
  force_delete = true
}