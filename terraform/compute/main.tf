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
