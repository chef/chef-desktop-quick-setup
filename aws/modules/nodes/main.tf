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

resource "aws_instance" "node" {
  count                       = var.node_count
  ami                         = "ami-0231704d6e7036502" # Windows base server 2019 ami
  instance_type               = var.windows_node_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.allow_rdp]
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  depends_on                  = [var.node_depends_on]

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
    Name        = "chef-desktop-quick-setup-node-${count.index}"
  }

  connection {
    type = "winrm"
    user = "user${count.index}"
    host = self.public_ip
  }

  # provisioner "file" {
  #   content = templatefile("${path.root}/../templates/client.rb.tpl", {
  #     node_name       = "node-${count.index}"
  #     user_name       = "user${count.index}"
  #     chef_server_url = var.chef_server_url
  #   })
  #   destination = "C:/chef/client.rb"
  # }

  # provisioner "chef" {
  #   client_options = ["chef_license 'accept'"]
  #   run_list       = ["desktop-config-lite::default"]
  #   node_name      = "node-${count.index}"
  #   # secret_key      = file("../encrypted_data_bag_secret")
  #   server_url      = var.chef_server_url
  #   recreate_client = true
  #   user_name       = "user${count.index}"
  #   user_key        = file("../user${count.index}.pem")
  #   version         = "16.9.29"
  #   # Since we have a self signed cert on our chef server we are setting this to :verify_none
  #   # In production we should get a certificate and configure for the server and set this to :verify_peer
  #   ssl_verify_mode = ":verify_none"
  # }
}

# resource "aws_eip" "eip" {
#   instance = aws_instance.automate.id
#   vpc      = true
# }
