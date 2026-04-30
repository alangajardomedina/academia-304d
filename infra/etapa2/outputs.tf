output "mysql_ip" {
  value = aws_instance.db.public_ip
}