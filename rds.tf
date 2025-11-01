# Create an Amazon RDS PostgreSQL instance in private subnets.

# DB Subnet Group

# Specifies the private subnets where RDS will live.
# Uses 2 subnets across 2 Availability Zones for high availability.

# RDS Instance

# Engine: postgres
# Version: 16.4
# Class: db.t3.micro (free-tier eligible)
# Encryption: enabled with KMS key
# Credentials: use random_password from Secrets Manager
# Multi-AZ: true for redundancy
# publicly_accessible = false

# End result: A secure, multi-AZ PostgreSQL database only accessible inside your VPC.

# DB Subnet Group (for private subnets)
resource "aws_db_subnet_group" "todo_rds_subnet_group" {
  name       = "todo_rds_subnet_group"
  subnet_ids = aws_subnet.todo_private_subnet[*].id

  tags = {
    Name = "todo-rds-subnet-group"
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "todo_rds" {
  identifier             = "todo-postgres"
  engine                 = "postgres"
  engine_version         = "16.8"
  instance_class         = var.rds_instance_class
  allocated_storage      = var.rds_allocated_storage
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.rds_password.result
  db_subnet_group_name   = aws_db_subnet_group.todo_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.todo_rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_kms.arn
  multi_az               = true

  tags = {
    Name = "todo-rds-instance"
  }

  depends_on = [
    aws_db_subnet_group.todo_rds_subnet_group,
    aws_kms_key.rds_kms
  ]
}
