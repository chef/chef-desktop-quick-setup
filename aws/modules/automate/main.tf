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


resource "aws_network_interface" "nic" {
  subnet_id   = var.subnet_id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}
# data "aws_ami" "amazon_linux_2" {
#   executable_users = ["self"]
#   most_recent      = true
#   # name_regex       = "^Amazon Linux 2 AMI (HVM)*"
#   owners           = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["Amazon Linux 2 AMI (HVM)*"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

resource "aws_instance" "automate" {
  ami = "ami-0db0b3ab7df22e366"
  # 4vCPUs, 16GB RAM - Based on minimum requirements for Automate server.
  # For more details, visit https://docs.chef.io/automate/system_requirements/
  instance_type               = "t2.xlarge"
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name

  # network_interface {
  #   network_interface_id = aws_network_interface.nic.id
  #   device_index = 0
  # }

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
  }

  connection {
    type = "ssh"
    user = var.admin_username
    host = self.public_ip
  }

  provisioner "file" {
    content     = templatefile("${path.root}/../templates/automate.config.toml.tpl", { automate_fqdn = self.public_dns })
    destination = "~/config.toml"
  }

  provisioner "file" {
    content = templatefile("${path.root}/../templates/automate.setup.sh.tpl", {
      user_name         = var.automate_credentials.user_name
      user_display_name = var.automate_credentials.user_display_name
      user_email        = var.automate_credentials.user_email
      user_password     = var.automate_credentials.user_password
      org_name          = var.automate_credentials.org_name
      org_display_name  = var.automate_credentials.org_display_name
      validator_path    = var.automate_credentials.validator_path
    })
    destination = "~/automate.setup.sh"
  }

  provisioner "remote-exec" {
    inline = ["/bin/bash ~/automate.setup.sh"]
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.automate.id
  vpc      = true
}
