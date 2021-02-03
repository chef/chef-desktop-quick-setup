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
  ami_id                  = data.aws_ami.ubuntu_1804.id
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
  ami_id            = data.aws_ami.windows_2019.id
  node_count        = 2
  resource_location = var.resource_location
  subnet_id         = aws_subnet.subnet.id
  allow_ssh         = aws_security_group.allow_ssh.id
  allow_rdp         = aws_security_group.allow_win_rdp_connection.id
  key_name          = aws_key_pair.awskp.key_name
  chef_server_url   = "https://${module.automate.automate_server_url}/organizations/${var.automate_credentials.org_name}"
  node_depends_on = [
    # Explicit dependency on the route table association with the subnet to make sure route tables are created when only automate module is run.
    aws_route_table_association.subnet_association
  ]
}

resource "aws_key_pair" "awskp" {
  key_name   = "awskp"
  public_key = file("./${var.public_key_path}")
}
