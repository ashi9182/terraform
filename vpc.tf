resource "aws_vpc" "vpcashishtf" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "vpc-ashish-tf"
  }
}

resource "aws_subnet" "publicashishtf" {
    vpc_id = aws_vpc.vpcashishtf.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
        Name = "public-ashish-tf"
    }
}

resource "aws_subnet" "privateashishtf" {
    vpc_id = aws_vpc.vpcashishtf.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "private-ashish-tf"
    }
}