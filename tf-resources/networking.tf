
resource "aws_vpc" "cluster-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

data "aws_availability_zones" "zone" {
}

resource "aws_subnet" "eks-subnets" {
  count                   = length(var.subnet_cidrs)
  vpc_id                  = aws_vpc.cluster-vpc.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.zone.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.cluster_name}-subnet-${count.index + 1}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}