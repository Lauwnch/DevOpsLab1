resource "aws_instance" "proxy" {
  //Default us-west-2 Ubuntu 16.04
  count = "${ var.num_proxy }"
  ami                    = "ami-09b42c38b449cfa59"
  instance_type          = "t2.micro"
  subnet_id              = "${ var.subnet }"
  key_name               = "worktop-general"
  vpc_security_group_ids = "${ aws_security_group.front.id }"

  //cross-module/module-module dependency not supported
  //depends_on = ["${ var.igw }"]

  tags = {
    Project = "devopslab1"
    Name    = "reverse proxy ${count.index}"
  }
}

resource "aws_instance" "cache" {
  //Default us-west-2 Ubuntu 16.04
  count = ${ var.num_cache }
  ami                    = "ami-09b42c38b449cfa59"
  instance_type          = "t2.micro"
  subnet_id              = "${ var.subnet }"
  key_name               = "worktop-general"
  vpc_security_group_ids = "${ aws_security_group.front.id }"

  //cross-module/module-module dependency not supported
  //depends_on = ["${ var.igw }"]

  tags = {
    Project = "devopslab1"
    Name    = "cache ${count.index}"
  }
}

resource "aws_security_group" "front" {
  name        = "3t_frontend_webserver"
  description = "Allows http(s) traffic and traffic to app layer"
  vpc_id      = "${ var.vpc }"

}

resource "aws_security_group_rule" "http_in" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = "0.0.0.0/0"
  security_group_id = "${ aws_security_group.front.id }"
}

resource "aws_security_group_rule" "https_in" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = "0.0.0.0/0"
  security_group_id = "${ aws_security_group.front.id }"
}

resource "aws_security_group_rule" "ssh_home" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  cidr_blocks       = "24.92.129.23/32"
  security_group_id = "${ aws_security_group.front.id }"
}

resource "aws_security_group_rule" "ssh_bastion" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "22"
  to_port           = "22"
  security_group    = "${ var.security_id_bastion }"
  security_group_id = "${ aws_security_group.front.id }"
}

resource "aws_security_group_rule" "http_out" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"
  cidr_blocks       = "0.0.0.0/0"
  security_group_id = "${ aws_security_group.front.id }"
}

resource "aws_security_group_rule" "https_out" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = "443"
  to_port           = "443"
  cidr_blocks       = "0.0.0.0/0"
  security_group_id = "${ aws_security_group.front.id }"
}

resource "aws_security_group_rule" "db_out" {
  type              = "egress"
  protocol          = "tcp"
  from_port         = "3306"
  to_port           = "3306"
  security_groups   = "${ var.security_id_db }"
  security_group_id = "${ aws_security_group.front.id }"
}
