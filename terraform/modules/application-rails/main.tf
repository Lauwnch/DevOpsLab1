resource "aws_instance" "application" {
  //Default us-west-2 Ubuntu 16.04
  ami                    = "${ var.ami_application }"
  instance_type          = "t2.micro"
  subnet_id              = "${ var.subnet }"
  key_name               = "worktop-general"
  vpc_security_group_ids = "${ aws_security_group.app.id }"

  tags = {
    Project = "devopslab1"
    Name    = "application server ${count.index}"
  }
}

resource "aws_security_group" "app" {
  name        = "3t_appserver"
  description = "Receives proxied reqs from proxy, outbound thru NAT, traffic from DB"
  vpc_id      = "${ var.vpc }"
}

resource "aws_security_group_rule" "ssh_bastion" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  security_groups   = "${ var.security_id_bastion }"
  security_group_id = "${ aws_security_group.app.id }"
}

resource "aws_security_group_rule" "http_in_proxy" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  security_groups   = "${ var.security_id_front }"
  security_group_id = "${ aws_security_group.app.id }"
}

resource "aws_security_group_rule" "https_in_proxy" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  security_groups   = "${ var.security_id_front }"
  security_group_id = "${ aws_security_group.app.id }"
}

resource "aws_security_group_rule" "http_out" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = "0.0.0.0/0"
  security_group_id = "${ aws_security_group.app.id }"
}

resource "aws_security_group_rule" "https_out" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = "0.0.0.0/0"
  security_group_id = "${ aws_security_group.app.id }"
}

resource "aws_security_group_rule" "ping" {
  type              = "egress"
  protocol          = "icmp"
  from_port         = "8"
  to_port           = "8"
  cidr_blocks       = "10.0.0.0/8"
  security_group_id = "${ aws_security_group.app.id }"
}

resource "aws_security_group_rule" "db_out" {
  type      = "egress"
  protocol  = "tcp"
  from_port = "3306"
  to_port   = "3306"

  //if this dep creates problems, can refactor by making this rule seperately defined, or by defining CIDR block and initating instance within it
  security_groups   = "${ var.security_id_db }"
  security_group_id = "${ aws_security_group.app.id }"
}
