data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = element(var.az,0)
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.env}-public-subnet"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet1_cidr
  availability_zone       = element(var.az,1)
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.env}-public-subnet1"
  }
}



resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.env}-internet-gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${var.env}-public-subnet-route-table"
  }
}

resource "aws_route_table" "public_rt1" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "${var.env}-public-subnet-route-table1"
  }
}

resource "aws_route_table_association" "to_public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "to_public_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt1.id
}

provider "aws" {
  region = var.aws_region
}

output "publicsubnetid" {
  description = "Subnet ID"
  value       = aws_subnet.public_subnet.id
}

output "publicsubnet1id" {
  description = "Subnet ID"
  value       = aws_subnet.public_subnet1.id
}

output "myvpcid" {
  description = "VPC ID"
  value       = aws_vpc.my_vpc.id
}