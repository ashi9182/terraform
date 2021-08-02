terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  

  required_version = ">= 0.14.9"

  backend "s3" {
    bucket = "ashish-bucket9183"
    key    = "tfstate/"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
}




resource "aws_security_group" "ssh-allowed" {
    name = "ashish-sg-us-east-1"
    vpc_id = aws_vpc.vpcashishtf.id
    
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    dynamic "ingress" {
      for_each = toset([22,80])
      content {
        from_port = ingress.value
        to_port =  ingress.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    tags = {
        Name = "ashish-sg-tf"
    }
    depends_on = [aws_vpc.vpcashishtf,]
}

resource "aws_instance" "ec2-ashish" {
  for_each = {
    ec2-ashish-1 = aws_subnet.publicashishtf.id
    ec2-ashish-2 = aws_subnet.privateashishtf.id
  }
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name = "my_aws_key_us"
  subnet_id = each.value
  vpc_security_group_ids = [aws_security_group.ssh-allowed.id]
  

  tags = {
    Name = each.key
  }
  depends_on = [aws_vpc.vpcashishtf,aws_route_table_association.ashish-crt1-public-ashish-tf]
}

