# Create:

# Web SG:
# |
# |
# Allows SSH (22) from your IP only.
# Allows HTTP (80) from anywhere.
# Allow all outbound traffic.

# App SG:
# |
# |
# Allows inbound 8080 only from Web SG.
# Allow all outbound traffic.

# RDS SG:
# |
# |
# Allows inbound 5432 only from App SG.
# Allow all outbound traffic.

# ----------------Web SG---------------------
resource "aws_security_group" "todo_web_sg" {
  name        = "todo_web_sg"
  description = "Allow all inbound and outbound traffic"
  vpc_id      = aws_vpc.todo_vpc.id

  tags = {
    Name = "todo-web-sg"
  }
}

# ----------------Allow inbound from my ip to Web SG---------------------
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.todo_web_sg.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# ----------------Allow inbound from http to Web SG---------------------
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.todo_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# ----------------Allow all outbound from Web SG---------------------
resource "aws_vpc_security_group_egress_rule" "web_out" {
  security_group_id = aws_security_group.todo_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ----------------App SG---------------------
resource "aws_security_group" "todo_app_sg" {
  name        = "todo_app_sg"
  description = "Allow inbound traffic only from web sg and allow all outbound traffic"
  vpc_id      = aws_vpc.todo_vpc.id

  tags = {
    Name = "todo_app_sg"
  }
}

# ----------------Allow inbound only from Web SG to App SG---------------------
resource "aws_vpc_security_group_ingress_rule" "allow_only_web_sg" {
  security_group_id            = aws_security_group.todo_app_sg.id
  referenced_security_group_id = aws_security_group.todo_web_sg.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# ----------------Allow all outbound from App SG---------------------
resource "aws_vpc_security_group_egress_rule" "app_out" {
  security_group_id = aws_security_group.todo_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ----------------DB Security Group — only accessible from App SG---------------------
resource "aws_security_group" "todo_rds_sg" {
  name        = "todo_rds_sg"
  description = "Allow PostgreSQL from App SG"
  vpc_id      = aws_vpc.todo_vpc.id

  tags = {
    Name = "todo-rds-sg"
  }
}

# ----------------Allow PostgreSQL from App SG---------------------
resource "aws_vpc_security_group_ingress_rule" "rds_from_app_sg" {
  security_group_id            = aws_security_group.todo_rds_sg.id
  referenced_security_group_id = aws_security_group.todo_app_sg.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# ----------------Allow all outbound from RDS SG---------------------
resource "aws_vpc_security_group_egress_rule" "rds_out" {
  security_group_id = aws_security_group.todo_rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
