/*
create a vpc
create 1 public subnets in different availability zones
create 2 private subnet in a different availability zone
create an internet gateway
create an elastic ip for nat gateway
create a nat gateway in the public subnet
create a route table for public subnets
create a route table for private subnets
create route table associations for public subnets
create route table associations for private subnets
create a route in the public route table to allow internet access
*/


resource "aws_vpc" "cluster-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

data "aws_availability_zones" "zone" {
}

resource "aws_subnet" "cluster-public-subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.cluster-vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.zone.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.cluster_name}-public-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "public"
  }
}

resource "aws_subnet" "cluster-private-subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.cluster-vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.zone.names[count.index + length(var.public_subnet_cidrs)]
  # Ensure private subnets are in different AZs than public subnets

  tags = {
    Name                                        = "${var.cluster_name}-private-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "private"
  }
}

resource "aws_internet_gateway" "cluster-igw" {
  vpc_id = aws_vpc.cluster-vpc.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

resource "aws_eip" "cluster-natgw-eip" {
  vpc = true
  tags = {
    Name = "nat-gateway-eip"
  }
}

resource "aws_nat_gateway" "cluster-natgw" {
  allocation_id = aws_eip.cluster-natgw-eip.id
  subnet_id     = aws_subnet.cluster-public-subnets[0].id

  tags = {
    Name = "${var.cluster_name}-nat-gateway"
  }
}

resource "aws_route_table" "cluster-public-rtb" {
  vpc_id = aws_vpc.cluster-vpc.id
  tags = {
    Name = "${var.cluster_name}-public-route-table"
  }
}

resource "aws_route_table" "cluster-private-rtb" {
  vpc_id = aws_vpc.cluster-vpc.id
  tags = {
    Name = "${var.cluster_name}-public-private-table"
  }
}

resource "aws_route_table_association" "cluster-public-rtb" {
  count          = length(aws_subnet.cluster-public-subnets)
  subnet_id      = aws_subnet.cluster-public-subnets[count.index].id
  route_table_id = aws_route_table.cluster-public-rtb.id
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.cluster-public-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cluster-igw.id
}

resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.cluster-private-rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.cluster-natgw.id
}

resource "aws_route_table_association" "cluster-private-rtb" {
  count          = length(aws_subnet.cluster-private-subnets)
  subnet_id      = aws_subnet.cluster-private-subnets[count.index].id
  route_table_id = aws_route_table.cluster-private-rtb.id
}
