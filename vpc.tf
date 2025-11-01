# Create one VPC.
# Define two public and two private subnets.
# Attach an Internet Gateway to allow public internet access.
# Allocate an Elastic IP for the NAT Gateway (so private subnets can go online).
# Create two route tables (public & private).
# Associate each subnet with the correct route table.

# ----------------VPC---------------------
resource "aws_vpc" "todo_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "todo-vpc"
  }
}

# ----------------Public Subnets---------------------
resource "aws_subnet" "todo_public_subnet" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.todo_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}${element(["a", "b"], count.index)}"

  tags = {
    Name = "todo-public-subnet-${count.index + 1}"
  }
}

# ----------------Private Subnets---------------------
resource "aws_subnet" "todo_private_subnet" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.todo_vpc.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = "${var.aws_region}${element(["a", "b"], count.index)}"

  tags = {
    Name = "todo-private-subnet-${count.index + 1}"
  }
}

# ----------------Internet Gateway---------------------
resource "aws_internet_gateway" "todo_igw" {
  vpc_id = aws_vpc.todo_vpc.id

  tags = {
    Name = "todo-igw"
  }
}

# ----------------Elastic IP for NAT Gateway---------------------
resource "aws_eip" "todo_eip" {
  domain = "vpc"

  tags = {
    Name = "todo-eip"
  }
}

# ----------------Netword Address Translation(NAT) Gateway---------------------
resource "aws_nat_gateway" "todo_nat_gw" {
  allocation_id = aws_eip.todo_eip.id
  subnet_id     = aws_subnet.todo_public_subnet[0].id
  depends_on    = [aws_internet_gateway.todo_igw]

  tags = {
    Name = "todo-nat-gw"
  }
}

# ----------------Route Tables---------------------
# ----------------Public Route Table---------------------
resource "aws_route_table" "todo_public_rt" {
  vpc_id = aws_vpc.todo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.todo_igw.id
  }

  tags = {
    Name = "todo-public-rt"
  }
}

# ----------------Private Route Table---------------------
resource "aws_route_table" "todo_private_rt" {
  vpc_id = aws_vpc.todo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.todo_nat_gw.id
  }

  tags = {
    Name = "todo-private-rt"
  }
}

# ----------------Route Table Association---------------------
# ----------------Public Route Table Association---------------------
resource "aws_route_table_association" "todo_public_rt_association" {
  count          = length(aws_subnet.todo_public_subnet)
  route_table_id = aws_route_table.todo_public_rt.id
  subnet_id      = aws_subnet.todo_public_subnet[count.index].id
}

# ----------------Private Route Table Association---------------------
resource "aws_route_table_association" "todo_private_rt_association" {
  count          = length(aws_subnet.todo_public_subnet)
  route_table_id = aws_route_table.todo_private_rt.id
  subnet_id      = aws_subnet.todo_private_subnet[count.index].id
}
