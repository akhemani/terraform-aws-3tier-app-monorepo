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
  default = "" #write your ip address
}

variable "key_name" {
  description = "EC2 Key pair for SSH access"
  type        = string
  default     = "" #write yours key value pair file name
}

variable "db_name" {
  description = "Database name"
  default     = "todoappdb"
}

variable "db_username" {
  description = "Database master username"
  default     = "dbadmin"
}

variable "rds_instance_class" {
  default = "db.t3.micro"
}

variable "rds_allocated_storage" {
  default = 20
}

variable "app_image" {
  description = "Container image to deploy"
  type        = string
}

# variable "domain_name" {
#   description = "Your base domain (e.g. example.com)"
#   type        = string
# }

# variable "app_subdomain" {
#   description = "Subdomain (e.g. app) so full name is app.example.com"
#   type        = string
# }

variable "container_port" {
  type    = number
  default = 8080
}

variable "desired_count" {
  type    = number
  default = 2
}

variable "task_cpu" {
  type    = number
  default = 256
}

variable "task_memory" {
  type    = number
  default = 512
}

variable "existing_execution_role_name" {
  type    = string
  default = "EcsTaskExecutionRole"
}

variable "certificate_arn" {
  description = "Certificate arn"
  type        = string
}