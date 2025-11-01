# Use a data source to fetch the latest Ubuntu AMI dynamically (so you always get a fresh image).
# Launch a t3.micro instance for both.
# Use the key pair you specify in variables (for SSH).
# Attach the correct security group & subnet to each.

# Result:

# Web EC2 has a public IP (reachable from internet).
# App EC2 is private (only reachable from web EC2).

# ----------------Find latest Ubuntu 22.04 AMI---------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

# ----------------Web EC2---------------------
resource "aws_instance" "todo_web_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.todo_public_subnet[0].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.todo_web_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "todo_web_ec2"
  }
}

# ----------------App EC2---------------------
resource "aws_instance" "todo_app_ec2" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.todo_private_subnet[0].id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.todo_app_sg.id]

  tags = {
    Name = "todo_app_ec2"
  }
}