provider "aws" {
  region = "us-west-2"
}

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
