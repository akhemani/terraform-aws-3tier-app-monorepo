# Output:

# Public IP of the web server
# Private IP of the app server
# VPC ID
# Private Subnet Ids
# RDS endpoint
# Secrets Manager ARN
# KMS key ARN

# ----------------Public IP of the web server---------------------
output "web_instance_public_ip" {
  value = aws_instance.todo_web_ec2.public_ip
}

# ----------------Private IP of the app server---------------------
# output "app_instance_private_ip" {
#   value = aws_instance.todo_app_ec2.private_ip
# }

# ----------------VPC ID---------------------
output "vpc_id" {
  value = aws_vpc.todo_vpc.id
}

# ----------------Private Subnet IDs---------------------
output "private_subnet_ids" {
  value = aws_subnet.todo_private_subnet[*].id
}

# ----------------Public Subnet IDs---------------------
output "public_subnet_ids" {
  value = aws_subnet.todo_public_subnet[*].id
}

# ----------------Public Subnet IDs---------------------
output "rds_endpoint" {
  value = aws_db_instance.todo_rds.endpoint
}

# ----------------Secrets Manager ARN---------------------
output "rds_secret_arn" {
  value = aws_secretsmanager_secret.rds_secret.arn
}

# ----------------KMS key ARN---------------------
output "rds_kms_key_arn" {
  value = aws_kms_key.rds_kms.arn
}

output "ecs_service_name" {
  value = aws_ecs_service.app_service.name
}

output "ecs_cluster_id" {
  value = aws_ecs_cluster.app_cluster.id
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = aws_lb.todo_app_alb.dns_name
}
