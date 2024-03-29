terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "dbaeten-terraform-day3-bucket"
    key = "terraform.tfstate"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = var.default_tags
  }
}

# Create a VPC: cidr 11.0.0.0/16
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    "Name" = "dbaeten"
  }
}

# Public Subnet: cidr 11.0.0.0/24
# Public Subnet: cidr 11.0.1.0/24
resource "aws_subnet" "public" {
  count = var.public_subnet_count
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index) # prefix, newbits, netnum
  ipv6_cidr_block = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index) # prefix, newbits, netnum
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.default_tags.env}-Public-Subnet-${data.aws_availability_zones.availability_zone.names[count.index]}" # terraform_testing-Public-Subnet-AZ
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index] # specifying the AZ the subnet is in
}

# Private Subnet: cidr 11.0.2.0/24
# Private Subnet: cidr 11.0.3.0/24
resource "aws_subnet" "private" {
  count = var.private_subnet_count
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.public_subnet_count) # prefix, newbits, netnum
   tags = {
    "Name" = "${var.default_tags.env}-Private-Subnet-${data.aws_availability_zones.availability_zone.names[count.index]}" # terraform_testing-Private-Subnet-AZ
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index] # specifying the AZ the subnet is in
}

# IGW
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-IGW"
  }
}

# Elastic IP
resource "aws_eip" "NAT_EIP" {
  vpc = true
}

# NAT Gateway
resource "aws_nat_gateway" "main_nat_gw" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id = aws_subnet.public.0.id
  tags = {
    "Name" = "${var.default_tags.env}-nat"
  }
}

# Public RT
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-public-rt"
  }
}

# Route for Public RT
resource "aws_route" "public" {
  route_table_id = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main_igw.id
}

# Route table associations
resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public-rt.id
  count = var.public_subnet_count
  subnet_id = element(aws_subnet.public.*.id, count.index)
}

# Private RT
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.default_tags.env}-private-rt"
  }
}

# Route for Private RT
resource "aws_route" "private" {
  route_table_id = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main_nat_gw.id
}

# Route table associations
resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.private-rt.id
  count = var.private_subnet_count
  subnet_id = element(aws_subnet.private.*.id, count.index)
}
