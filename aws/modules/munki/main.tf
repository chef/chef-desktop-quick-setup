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
  availability_zone      = var.macdhost_availability_zone
  host_id                = var.macdhost_id
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id
  key_name               = var.key_name
}

resource "aws_eip" "eip" {
  instance = aws_instance.munki_server.id
  vpc      = true
}
