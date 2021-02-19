terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.resource_location
}

resource "aws_instance" "munki_server" {
  ami                    = var.ami_id
  instance_type          = "mac1.metal"
  host_id                = var.macdhost_id
  associate_public_ip_address = true
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  depends_on = [ var.munki_depends_on ]
  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
    Name = "cdqs-munki"
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.munki_server.id
  vpc      = true
}
