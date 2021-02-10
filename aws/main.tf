terraform {
  # This module has been written with terraform v0.14.6. To allow future upgrades, setting the supported version to be this or higher.
  required_version = "0.14.6"
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
    aws_route_table_association.subnet_association,
  ]
  knife_profile_name = var.knife_profile_name
  policy_name = var.policy_name
}

# Module for creating the munki repo and pushing to s3 bucket.
# module "munki" {
#   source            = "./modules/munki"
#   resource_location = var.resource_location
#   subnet_id         = aws_subnet.subnet.id
#   security_group_id = aws_security_group.allow_ssh.id
#   key_name          = aws_key_pair.awskp.key_name
# }

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
  admin_password    = var.admin_password_win_node
  resource_location = var.resource_location
  subnet_id         = aws_subnet.subnet.id
  allow_ssh         = aws_security_group.allow_ssh.id
  allow_rdp         = aws_security_group.allow_win_rdp_connection.id
  key_name          = aws_key_pair.awskp.key_name
  chef_server_url   = "https://${module.automate.automate_server_url}/organizations/${var.automate_credentials.org_name}"
  client_name       = var.automate_credentials.user_name
  node_depends_on = [
    # Explicit dependency on the route table association with the subnet to make sure route tables are created when only nodes module is run.
    aws_route_table_association.subnet_association
  ]
  node_setup_depends_on = [
    module.automate.automate_server_setup, #The node setup implicitly depends on this resource, but it is mentioned here to avoid ambiguity.
    module.automate.setup_policy
  ]
}

resource "aws_key_pair" "awskp" {
  key_name   = "awskp"
  public_key = file("./${var.public_key_path}")
}
