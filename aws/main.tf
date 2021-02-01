terraform {
  # This module has been written with terraform v0.14.3. To allow future upgrades, setting the supported version to be this or higher.
  required_version = "0.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider.
provider "aws" {
  region = var.resource_location
}

# Module for creating automate 2 server.
module "automate" {
  source                  = "./modules/automate"
  admin_username          = var.admin_username
  private_key_path        = var.private_key_path
  resource_location       = var.resource_location
  subnet_id               = aws_subnet.subnet.id
  automate_credentials    = var.automate_credentials
  security_group_id       = aws_security_group.allow_ssh.id
  key_name                = aws_key_pair.awskp.key_name
  automate_dns_name_label = var.automate_dns_name_label
  automate_depends_on = [
    # Explicit dependency on the route table association with the subnet to make sure route tables are created when only automate module is run.
    aws_route_table_association.subnet_association
  ]
}

# Module for creating the munki repo and pushing to s3 bucket.
module "munki" {
  source            = "./modules/munki"
  resource_location = var.resource_location
  subnet_id         = aws_subnet.subnet.id
  security_group_id = aws_security_group.allow_ssh.id
  key_name          = aws_key_pair.awskp.key_name
}

# Module for creating the gorilla repo and pushing to s3 bucket.
module "gorilla" {
  source            = "./modules/gorilla"
  resource_location = var.resource_location
}

# Module for creating virtual nodes.
module "nodes" {
  source            = "./modules/nodes"
  node_count        = 2
  resource_location = var.resource_location
  subnet_id         = aws_subnet.subnet.id
  allow_ssh         = aws_security_group.allow_ssh.id
  allow_rdp         = aws_security_group.allow_win_rdp_connection.id
  key_name          = aws_key_pair.awskp.key_name
  chef_server_url   = module.automate.automate_server_url
  node_depends_on = [
    # Explicit dependency on the route table association with the subnet to make sure route tables are created when only automate module is run.
    aws_route_table_association.subnet_association
  ]
}

# Create a private cloud.
resource "aws_vpc" "vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
  }
}

# Create an internet gateway.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
  }
}

# Create a public subnet.
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.16.0.0/24"
  # cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
  }
}

# Create route table and attach it to the internet gateway.
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

# Associate route table with subnet.
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# Security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc.id

  # Allow anyone to connect to port 22
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Re create the default allow all egress rule.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_win_rdp_connection" {
  name        = "allow_win_rdp_connection"
  description = "Allow RDP clients to connect to windows nodes"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Re create the default allow all egress rule.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "awskp" {
  key_name   = "awskp"
  public_key = file("./${var.public_key_path}")
}
