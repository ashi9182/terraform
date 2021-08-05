terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }



  required_version = ">= 0.14.9"

  backend "s3" {
    bucket = "ashish-bucket9184"
    key    = "tfstate/"
    region = "ap-south-1"
  }
}

provider "aws" {
  region  = "us-east-1"
}


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

resource "aws_internet_gateway" "ashish-igw" {
    vpc_id = aws_vpc.vpcashishtf.id
    tags = {
        Name = "ashish-igw"
    }
}

resource "aws_route_table" "ashish-crt1" {
    vpc_id = aws_vpc.vpcashishtf.id
    
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.ashish-igw.id 
    }
    
    tags = {
        Name = "ashish-crt1"
    }
}


resource "aws_route_table_association" "ashish-crt1-public-ashish-tf"{
    subnet_id = aws_subnet.publicashishtf.id
    route_table_id = aws_route_table.ashish-crt1.id
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
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}


resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

resource "aws_launch_configuration" "ecs_launch_config" {
    image_id             = "ami-09e67e426f25ce0d7"
    iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
    security_groups      = [aws_security_group.ssh-allowed.id]
    user_data            = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
    instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
    name                      = "asg"
    vpc_zone_identifier       = [aws_subnet.publicashishtf.id]
    launch_configuration      = aws_launch_configuration.ecs_launch_config.name

    desired_capacity          = 2
    min_size                  = 1
    max_size                  = 10
    health_check_grace_period = 300
    health_check_type         = "EC2"
}


resource "aws_ecs_cluster" "ecs_cluster" {
    name  = "my-cluster"
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = "sample"
  container_definitions = file("task_definition.json")
}

resource "aws_ecs_service" "sampleservice" {
  name            = "sampleservice"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 2
}