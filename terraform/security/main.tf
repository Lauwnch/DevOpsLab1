resource "aws_security_group" "front" {
  name        = "3t_frontend_webserver"
  description = "Allows http(s) traffic and traffic to app layer"
  vpc_id      = "aws_vpc.project_network.id"

  ingress {
    // HTTP inbound
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = "0.0.0.0/0"
  }

  ingress {
    // HTTPS inbound
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = "0.0.0.0/0"
  }

  ingress {
    // SSH from home
    protocol    = "tcp"
    from_port   = "22"
    to_port     = "22"
    cidr_blocks = "24.92.129.23/32"
  }

  ingress {
    // SSH from bastion
    protocol       = "tcp"
    from_port      = "22"
    to_port        = "22"
    security_group = "${ aws_security_group.bastion.id }"
  }

  egress {
    // HTTP outbound
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    //HTTPs outbound
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    // HTTP outbound
    protocol       = "tcp"
    from_port      = "80"
    to_port        = "80"
    security_group = "${ aws_security_group.app.id }"
  }

  egress {
    //db outbound
    protocol        = "tcp"
    from_port       = "3306"
    to_port         = "3306"
    security_groups = "${ aws_security_group.db.id }"
  }
}

resource "aws_security_group" "bastion" {
  name        = "3t_bastion"
  description = "Allows ssh to app/db layer"
  vpc_id      = "aws_vpc.project_network.id"

  ingress {
    // SSH from home
    protocol    = "tcp"
    from_port   = "22"
    to_port     = "22"
    cidr_blocks = "24.92.129.23/32"
  }

  ingress {
    //SSH from self
    protocol  = "tcp"
    from_port = "22"
    to_port   = "22"
    self      = true
  }

  egress {
    //HTTP outbound
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    //HTTPS outbound
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    //SSH to private subnet
    protocol    = "tcp"
    from_port   = "22"
    to_port     = "22"
    cidr_blocks = "10.0.100.0/24"
  }
}

resource "aws_security_group" "app" {
  name        = "3t_appserver"
  description = "Receives proxied reqs from proxy, outbound thru NAT, traffic from DB"
  vpc_id      = "aws_vpc.project_network.id"

  ingress {
    //SSH from bastion
    protocol        = "tcp"
    from_port       = "22"
    to_port         = "22"
    security_groups = "${ aws_security_group.bastion.id }"
  }

  ingress {
    //HTTP from proxy
    protocol        = "tcp"
    from_port       = "80"
    to_port         = "80"
    security_groups = "${ aws_security_group.front.id }"
  }

  ingress {
    //HTTPS from proxy
    protocol        = "tcp"
    from_port       = "443"
    to_port         = "443"
    security_groups = "${ aws_security_group.front.id }"
  }

  egress {
    //HTTP outbound
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    //HTTPS outbound
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    //ping rule
    protocol    = "icmp"
    from_port   = "8"
    to_port     = "8"
    cidr_blocks = "10.0.0.0/8"
  }

  egress {
    //db outbound
    protocol  = "tcp"
    from_port = "3306"
    to_port   = "3306"

    //if this dep creates problems, can refactor by making this rule seperately defined, or by defining CIDR block and initating instance within it
    cidr_blocks = "${ aws_instance.database.private_ip }/32"
  }
}

resource "aws_security_group" "db" {
  name        = "3t_database"
  description = "Allows http(s) traffic and traffic to app layer"
  vpc_id      = "aws_vpc.project_network.id"

  ingress {
    protocol        = "tcp"
    from_port       = "3306"
    to_port         = "3306"
    security_groups = "${ aws_security_group.app.id }"
  }

  ingress {
    protocol        = "tcp"
    from_port       = "22"
    to_port         = "22"
    security_groups = "${ aws_security_group.bastion.id }"
  }

  ingress {
    protocol  = "tcp"
    self      = true
    from_port = "0"
    to_port   = "0"
  }

  egress {
    protocol    = "tcp"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = "0.0.0.0/0"
  }

  egress {
    //ping rule
    protocol    = "icmp"
    from_port   = "8"
    to_port     = "8"
    cidr_blocks = "10.0.0.0/8"
  }
}
