terraform {
  required_version = ">= 1.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_vpc" "ecs_project_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.app_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.ecs_project_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.app_name}-${var.environment}-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.ecs_project_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.app_name}-${var.environment}-private-subnet-${count.index + 1}"
  }
}

resource "aws_db_subnet_group" "db_sub_group" {
  name = "${var.app_name}-${var.environment}-db-subnet-group"

  subnet_ids = aws_subnet.private_subnet[*].id

  tags = {
    Name = "${var.app_name}-${var.environment}-db-subnet-group"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecs_project_vpc.id

  tags = {
    Name = "${var.app_name}-${var.environment}-igw"
  }
}

resource "aws_eip" "ngw_eip" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = {
    Name = "${var.app_name}-${var.environment}-ngw-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "ngw" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.ngw_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.app_name}-${var.environment}-ngw-${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ecs_project_vpc.id

  route {
    cidr_block = var.all_ip_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.ecs_project_vpc.id

  route {
    cidr_block     = var.all_ip_cidr
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }

  tags = {
    Name = "${var.app_name}-${var.environment}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_rta" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}