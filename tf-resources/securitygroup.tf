
resource "aws_security_group" "bastion-sg" {
  name        = "${var.cluster_name}-bastion-sg"
  description = "Bastion security group"
  vpc_id      = aws_vpc.cluster-vpc.id

  tags = {
    Name = "${var.cluster_name}-bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_b" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = aws_vpc.cluster-vpc.cidr_block
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_traffic_b" {
  security_group_id = aws_security_group.bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_security_group" "control-plane-sg" {
  name        = "${var.cluster_name}-control-plane-sg"
  description = "kubernetes control plane security group"
  vpc_id      = aws_vpc.cluster-vpc.id

  tags = {
    Name = "${var.cluster_name}-control-plane-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh_cp" {
  security_group_id = aws_security_group.control-plane-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "control_plane_components" {
  security_group_id = aws_security_group.control-plane-sg.id
  cidr_ipv4         = aws_vpc.cluster-vpc.cidr_block
  from_port         = 10250
  to_port           = 10259
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "kubernetes_api" {
  security_group_id = aws_security_group.control-plane-sg.id
  cidr_ipv4         = aws_vpc.cluster-vpc.cidr_block
  from_port         = 6443
  to_port           = 6443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "etcd_access" {
  security_group_id = aws_security_group.control-plane-sg.id
  cidr_ipv4         = aws_vpc.cluster-vpc.cidr_block
  from_port         = 2379
  to_port           = 2380
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_traffic_cp" {
  security_group_id = aws_security_group.control-plane-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_security_group" "worker-sg" {
  name        = "${var.cluster_name}-worker-sg"
  description = "kubernetes worker security group"
  vpc_id      = aws_vpc.cluster-vpc.id

  tags = {
    Name = "${var.cluster_name}-worker-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "kubelet_api" {
  security_group_id = aws_security_group.worker-sg.id
  cidr_ipv4         = aws_vpc.cluster-vpc.cidr_block
  from_port         = 10250
  to_port           = 10250
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh_w" {
  security_group_id = aws_security_group.worker-sg.id
  cidr_ipv4         = aws_vpc.cluster-vpc.cidr_block
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "node_port_services" {
  security_group_id = aws_security_group.worker-sg.id
  cidr_ipv4         = aws_vpc.cluster-vpc.cidr_block
  from_port         = 30000
  to_port           = 32767
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all_traffic_w" {
  security_group_id = aws_security_group.worker-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
