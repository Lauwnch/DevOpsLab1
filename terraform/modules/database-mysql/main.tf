resource "aws_instance" "database" {
  //Default us-west-2 Ubuntu 16.04
  count = var.num_databases
  ami                    = var.ami_cache
  instance_type          = "t2.micro"
  subnet_id              = "${ var.subnet }"
  key_name               = "worktop-general"
  vpc_security_group_ids = "${ aws_security_group.db.id }"
  private_ip             = var.private_ip[count.index]

  tags = {
    Project = "devopslab1"
    Name    = "database server ${ count.index }"
  }
}

resource "aws_security_group" "db" {
  name        = "3t_database"
  description = "Allows http(s) traffic and traffic to app layer"
  vpc_id      = "${ var.vpc }"
}

resource "aws_security_group_rule" "mysql_from_app" {
    type            = "ingress"
    protocol        = "tcp"
    from_port       = "3306"
    to_port         = "3306"
    security_groups = "${ var.security_id_app }"
  }

resource "aws_security_group_rule" "ssh_from_bastion" {
    type            = "ingress"
    protocol        = "tcp"
    from_port       = "22"
    to_port         = "22"
    security_groups = "${ var.security_id_bastion }"
  }

resource "aws_security_group_rule" "tcp_self" {
    type      = "ingress"
    protocol  = "tcp"
    self      = true
    from_port = "0"
    to_port   = "0"
  }

resource "aws_security_group_rule" "http_out" {
    type        = "egress"
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = "0.0.0.0/0"
  }

resource "aws_security_group_rule" "https_out" {
    type        = "egress"
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = "0.0.0.0/0"
  }

resource "aws_security_group_rule" "ping" {
    type        = "egress"
    protocol    = "icmp"
    from_port   = "8"
    to_port     = "8"
    cidr_blocks = "10.0.0.0/8"
  }
}