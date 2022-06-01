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

locals {
  fullPathToModule = abspath("${path.module}/main.tf")
  isMacOS          = substr(local.fullPathToModule, 0, 1) == "/"
}

resource "aws_instance" "automate" {
  ami = var.ami_id
  # 4vCPUs, 16GB RAM - Based on minimum requirements for Automate server.
  # For more details, visit https://docs.chef.io/automate/system_requirements/
  instance_type               = "t2.xlarge"
  associate_public_ip_address = true
  vpc_security_group_ids      = var.security_group_ids
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  depends_on                  = [var.automate_depends_on]

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
    Name        = "cdqs-A2server"
  }

  root_block_device {
    volume_size = 100
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.automate.id
  vpc      = true
}

# Create a knife profile and add it to ~/.chef/credentials
resource "local_file" "knife_profile" {
  content = templatefile("${path.root}/../templates/knife_profile.tpl", {
    knife_profile_name       = var.knife_profile_name
    client_name              = var.automate_credentials.user_name
    automate_client_key_file = "${abspath(path.root)}/../keys/${var.automate_credentials.user_name}.pem"
    chef_server_url          = "https://${aws_eip.eip.public_dns}/organizations/${var.automate_credentials.org_name}"
  })
  filename = "${path.root}/../.cache/knife_profile"
}
