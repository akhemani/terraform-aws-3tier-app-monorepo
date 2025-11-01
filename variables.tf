# create variables for:

# AWS region
# VPC CIDR block
# Public and private subnets (list of CIDRs)
# EC2 key pair name (so you can SSH later)

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "my_ip" {
  default = "" #write your ip here
}

variable "key_name" {
  description = "EC2 Key pair for SSH access"
  type        = string
  default     = "" #write your key value pair name
}

variable "db_name" {
  description = "Database name"
  default     = "todoappdb"
}

variable "db_username" {
  description = "Database master username"
  default     = "admin"
}

variable "rds_instance_class" {
  default = "db.t3.micro"
}

variable "rds_allocated_storage" {
  default = 20
}
