
resource "aws_security_group" "bastion-sg" {
  name        = "${var.cluster_name}-bastion-sg"
  description = "Bastion security group"
  vpc_id      = aws_vpc.cluster-vpc.id

  tags = {
    Name = "${var.cluster_name}-bastion-sg"
  }

  ingress {
    cidr_blocks = ["49.47.217.245/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_security_group" "control-plane-sg" {
  name        = "${var.cluster_name}-control-plane-sg"
  description = "kubernetes control plane security group"
  vpc_id      = aws_vpc.cluster-vpc.id

  tags = {
    Name = "${var.cluster_name}-control-plane-sg"
  }

  ingress {
    cidr_blocks = ["${aws_instance.bastion.public_ip}/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [aws_vpc.cluster-vpc.cidr_block]
    from_port   = 10250
    to_port     = 10259
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [aws_vpc.cluster-vpc.cidr_block]
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [aws_vpc.cluster-vpc.cidr_block]
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

}

resource "aws_security_group" "worker-sg" {
  name        = "${var.cluster_name}-worker-sg"
  description = "kubernetes worker security group"
  vpc_id      = aws_vpc.cluster-vpc.id

  tags = {
    Name = "${var.cluster_name}-worker-sg"
  }

  ingress {
    cidr_blocks = ["${aws_instance.bastion.public_ip}/32"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = [aws_vpc.cluster-vpc.cidr_block]
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
  }
  ingress {
    cidr_blocks = [aws_vpc.cluster-vpc.cidr_block]
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}
