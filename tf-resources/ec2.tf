

resource "aws_key_pair" "deployer" {
  key_name   = "coimbatore-cluster-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCk32HB+6NhU2+ZRbbxcw6wEUoCY0eFIu7jTuz5cYp6AOJJjJg7HejaJJCvNpj/TMEGaodqhbrYhTJgGtNGLlE3EIKvAoExwK6SNEXV5bn9x5gJfa33omEkZX/CeJJGY0qBPXwDSIHQeUDdNAWsa+cWsc4R/v1agoVUNkWZOvWysGrVrZgKQVlIkME4tTym90Rt8TYk0aPGTzaxpMyQ7l2ZmO5/cYHRiUyabaylRg7C5cs+axVwSvOxc/pNdZcTfU4ryWq/LQ880+x4jM0d6PMiAFKtppr+Cun87o/rkAn8PBD+ef2cRj5AfrBtsKVvqtk65c31+33etaNyaGF35C0igaGrNdGVrJWpcO1XQ1qLUFzR5O+UTyHiR7NrwHLx7E8ubmKJoWz10CgctIC6SaJF84JUM8fbVVR4s5Gat/1/KhpwyW+JZherSu+O/C/46NWcb1LhycpIwM2HDyNrDsEnEzpnTmwrFdxJOhCNjcpg7CvsZSSznDbxber2btJimNHHlPS4bXGIF3/4WSYDDLKISRle+RmDc6pRicn10r6Nx62qjDa6xI1YYnh4PXZ5ZjS1hlzJDtXybNVR1dZPTE3xUM0p3Dlt3y6SIrwpgSTCRWowpJ8sksPTXllbB6awO2Z2KAveMHlKikMYRrqTGk0aFO+CbWm1M8eSjAHSGjpJ3Q== gowthamshankarkrishnamoorthy@Gowthams-MacBook-Pro.local"
}

data "aws_ami" "cluster-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.cluster-ami.id
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = aws_subnet.cluster-public-subnets[0].id
  associate_public_ip_address = true
  security_group_id           = aws_security_group.control-plane-sg.id

  tags = {
    Name = "${var.cluster_name}-bastion"
  }
}