resource "aws_instance" "bastion" {
  //Default us-west-2 Ubuntu 16.04
  ami                    = "${ var.ami_bastion }"
  instance_type          = "t2.micro"
  subnet_id              = "${ var.subnet }"
  key_name               = "worktop-general"
  vpc_security_group_ids = "${ aws_security_group.bastion.id }"

  //cross-module/module-module dependency not supported
  //depends_on = ["aws_internet_gateway.front"]

  tags = {
    Project = "devopslab1"
    Name    = "bastion host"
  }
}

resource "aws_security_group" "bastion" {
  name        = "3t_bastion"
  description = "Allows ssh to app/db layer"
  vpc_id      = "${ var.vpc }"
}

resource "aws_security_group_rule" "ssh_in" {
    count             = length(var.allowed_cidrs)
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "22"
    to_port           = "22"
    cidr_blocks       = var.allowed_cidrs[count.index]
    security_group_id = "${ aws_security_group.bastion.id }"
  }

resource "aws_security_group_rule" "ssh_bastion" {
    type              = "ingress"
    protocol          = "tcp"
    from_port         = "22"
    to_port           = "22"
    self              = true
    security_group_id = "${ aws_security_group.bastion.id }"
  }

resource "aws_security_group_rule" "http_out" {
    type              = "egress"
    protocol          = "tcp"
    from_port         = "80"
    to_port           = "80"
    cidr_blocks       = "0.0.0.0/0"
    security_group_id = "${ aws_security_group.bastion.id }"
  }

resource "aws_security_group_rule" "https_out" {
    type              = "egress"
    protocol          = "tcp"
    from_port         = "443"
    to_port           = "443"
    cidr_blocks       = "0.0.0.0/0"
    security_group_id = "${ aws_security_group.bastion.id }"
  }

resource "aws_security_group_rule" "ssh_out" {
    type              = "egress"
    protocol          = "tcp"
    from_port         = "22"
    to_port           = "22"
    cidr_blocks       = "0.0.0.0/0"
    security_group_id = "${ aws_security_group.bastion.id }"
  }
}