provider "aws" {
  region                  = "us-west-2"
  shared_credentials_file = "$HOME/.aws/credentials"
}

///////////////
//NETWORK//
///////////////
resource "aws_vpc" "project_network" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Project = "devopslab1"
    Name    = "main"
  }
}

//eventually will replicate this on a second AZ
resource "aws_subnet" "public" {
  vpc_id     = "${ aws_vpc.project_network.id }"
  cidr_block = "10.0.1.0/24"

  tags = {
    Project = "devopslab1"
    Name    = "public subnet"
  }
}

//eventually will replicate this on a second AZ
resource "aws_subnet" "private" {
  vpc_id     = "${ aws_vpc.project_network.id }"
  cidr_block = "10.0.100.0/24"

  tags = {
    Project = "devopslab1"
    Name    = "private subnet"
  }
}

resource "aws_internet_gateway" "front" {
  vpc_id = "${ aws_vpc.project_network.id }"
}

resource "aws_nat_gateway" "app" {
  allocation_id = "${ aws_eip.nat.id }"
  subnet_id     = "${ aws_subnet.private.id }"

  depends_on = ["aws_internet_gateway.front"]

  tags = {
    Project = "devopslab1"
    Name    = "application nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${ aws_vpc.project_network.id }"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${ aws_internet_gateway.front.id }"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id          = "${ aws_subnet.public.id }"
  aws_route_table_id = "${ aws_route_table.public.id }"
}

resource "aws_route_table" "private" {
  vpc_id = "${ aws_vpc.project_network.id }"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${ aws_nat_gateway.app.id }"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id          = "${ aws_subnet.private.id }"
  aws_route_table_id = "${ aws_route_table.private.id }"
}

resource "aws_eip" "nat" {
  vpc = true

  depends_on = ["aws_internet_gateway.front"]
}

resource "aws_eip" "front" {
  vpc      = true
  instance = "${ aws_instance.proxy.id }"

  depends_on = ["aws_internet_gateway.front"]
}

///////////////
//SECURITY//
///////////////
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
    //HTTP outbound
    protocol    = "tcp"
    from_port   = "443"
    to_port     = "443"
    cidr_blocks = "0.0.0.0/0"
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

///////////////
//COMPUTE//
///////////////
//TO-DO Import this key, and get TF to recognize my general creds first
resource "aws_key_pair" "worktop" {}

resource "aws_instance" "proxy" {
  //Default us-west-2 Ubuntu 16.04
  ami                    = "ami-09b42c38b449cfa59"
  instance_type          = "t2.micro"
  subnet_id              = "${ aws_subnet.public.id }"
  key_name               = "worktop-general"
  vpc_security_group_ids = "${ aws_security_group.front.id }"

  depends_on = ["aws_internet_gateway.front"]

  tags = {
    Project = "devopslab1"
    Name    = "reverse proxy"
  }
}

resource "aws_instance" "bastion" {
  //Default us-west-2 Ubuntu 16.04
  ami                    = "ami-09b42c38b449cfa59"
  instance_type          = "t2.micro"
  subnet_id              = "${ aws_subnet.public.id }"
  key_name               = "worktop-general"
  vpc_security_group_ids = "${ aws_security_group.bastion.id }"

  depends_on = ["aws_internet_gateway.front"]

  tags = {
    Project = "devopslab1"
    Name    = "bastion host"
  }
}

resource "aws_instance" "application" {
  //Default us-west-2 Ubuntu 16.04
  ami                    = "ami-09b42c38b449cfa59"
  instance_type          = "t2.micro"
  subnet_id              = "${ aws_subnet.private.id }"
  key_name               = "worktop-general"
  vpc_security_group_ids = "${ aws_security_group.app.id }"

  tags = {
    Project = "devopslab1"
    Name    = "application server"
  }
}

resource "aws_instance" "database" {
  //Default us-west-2 Ubuntu 16.04
  ami                    = "ami-09b42c38b449cfa59"
  instance_type          = "t2.micro"
  subnet_id              = "${ aws_subnet.private.id }"
  key_name               = "worktop-general"
  vpc_security_group_ids = "${ aws_security_group.db.id }"

  tags = {
    Project = "devopslab1"
    Name    = "database server"
  }
}
