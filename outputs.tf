# Output:

# Public IP of the web server
# Private IP of the app server
# VPC ID

# ----------------Public IP of the web server---------------------
output "web_instance_public_ip" {
  value = aws_instance.todo_web_ec2.public_ip
}

# ----------------Private IP of the app server---------------------
output "app_instance_private_ip" {
  value = aws_instance.todo_app_ec2.private_ip
}

# ----------------VPC ID---------------------
output "vpc_id" {
  value = aws_vpc.todo_vpc.id
}
