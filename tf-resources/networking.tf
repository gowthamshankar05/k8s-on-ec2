
# resource "aws_vpc" "cluster-vpc" {
#   cidr_block       = "10.0.0.0/16"
#   instance_tenancy = "default"
#   tags = {
#     Name = "${var.cluster_name}-vpc"
#   }
# }

# data "aws_availability_zones" "zone" {
# }

# resource "aws_subnet" "eks-subnets" {
#   count                   = length(var.subnet_cidrs)
#   vpc_id                  = aws_vpc.cluster-vpc.id
#   cidr_block              = var.subnet_cidrs[count.index]
#   availability_zone       = data.aws_availability_zones.zone.names[count.index]
#   map_public_ip_on_launch = true

#   tags = {
#     Name                                        = "${var.cluster_name}-subnet-${count.index + 1}"
#     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
#   }
# }

# resource "aws_internet_gateway" "cluster-igw" {
#   vpc_id = aws_vpc.cluster-vpc.id

#   tags = {
#     Name = "${var.cluster_name}-igw"
#   }
# }

# resource "aws_route_table" "cluster-rtb" {
#   count  = length(aws_subnet.eks-subnets)
#   vpc_id = aws_vpc.cluster-vpc.id

#   route {
#     cidr_block           = aws_subnet.eks-subnets[count.index].cidr_block
#     network_interface_id = aws_network_interface.cluster-nif[count.index].id
#   }

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.cluster-igw.id
#   }
# }

# resource "aws_network_interface" "cluster-nif" {
#   count     = length(aws_subnet.eks-subnets)
#   subnet_id = aws_subnet.eks-subnets[count.index].id

#   tags = {
#     Name = "${var.cluster_name}-nif-${count.index + 1}"
#   }
# }