terraform {
  # This module has been written with terraform v0.14.3. To allow future upgrades, setting the supported version to be this or higher.
  required_version = ">= 0.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.resource_location
}

module "automate" {
  source               = "./modules/automate"
  admin_username       = var.admin_username
  private_key_path     = var.private_key_path
  resource_location    = var.resource_location
  subnet_id            = aws_subnet.subnet.id
  automate_credentials = var.automate_credentials
  security_group_id    = aws_security_group.allow_ssh.id
  key_name             = aws_key_pair.awskp.key_name
}

module "munki" {
  source = "./modules/munki"
}

module "gorilla" {
  source = "./modules/gorilla"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = var.availability_zone

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   description = "HTTPS"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "HTTP"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "awskp" {
  key_name   = "awskp"
  public_key = var.public_key
}
