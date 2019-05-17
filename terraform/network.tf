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
