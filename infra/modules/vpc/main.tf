resource "aws_vpc" "ecs_project_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "airtrail-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.ecs_project_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "airtrail-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.ecs_project_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "airtrail-public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.ecs_project_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = false

  tags = {
    Name = "airtrail-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.ecs_project_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "airtrail-private-subnet-2"
  }
}

resource "aws_db_subnet_group" "db_sub_group" {
  name = "airtrail_db_subnet_group"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.ecs_project_vpc.id

  tags = {
    Name = "airtrail-igw"
  }
}

resource "aws_eip" "ngw_eip_1" {
  domain = "vpc"

  tags = {
    Name = "airtrail-ngw-eip-1"
  }
}

resource "aws_eip" "ngw_eip_2" {
  domain = "vpc"

  tags = {
    Name = "airtrail-ngw-eip-2"
  }
}

resource "aws_nat_gateway" "ngw_1" { 
  allocation_id = aws_eip.ngw_eip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id 
  depends_on    = [aws_internet_gateway.igw] 
  
  tags = {
    Name = "ngw-1" }
} 

resource "aws_nat_gateway" "ngw_2" { 
  allocation_id = aws_eip.ngw_eip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id 
  depends_on    = [aws_internet_gateway.igw] 
  
  tags = { 
    Name = "ngw-2" }
}

resource "aws_route_table" "public_rt" {
  vpc_id     = aws_vpc.ecs_project_vpc.id

  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "airtrail-public-rt"
  }
}

resource "aws_route_table" "private_rt_1" {
  vpc_id     = aws_vpc.ecs_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_1.id
  }

  tags = {
    Name = "airtrail-private-rt-1"
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id     = aws_vpc.ecs_project_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_2.id
  }

  tags = {
    Name = "airtrail-private-rt-2"
  }
}

resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt_1.id
  depends_on     = [aws_nat_gateway.ngw_1]
}

resource "aws_route_table_association" "private_rta_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt_2.id
  depends_on     = [aws_nat_gateway.ngw_2]
}