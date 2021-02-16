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
    # Explicit dependency on the route table association with the subnet to make sure route tables are created when automate module is run.
    aws_route_table_association.subnet_association,
  ]
  knife_profile_name = var.knife_profile_name
  policy_name        = var.policy_name
}

# Set up IAM profile to provide access to s3 bucket from virtual nodes.
module "iam" {
  source = "./modules/iam"
}

# Module for creating the munki repo and pushing to s3 bucket.
# module "munki" {
#   source            = "./modules/munki"
#   ami_id            = data.aws_ami.macos_catalina.id
#   resource_location = var.macdhost_availability_zone
#   subnet_id         = aws_subnet.macdhost_vpc_subnet.id
#   security_group_id = aws_security_group.allow_ssh.id
#   key_name          = aws_key_pair.awskp_mac.key_name
#   host_id           = var.macdhost_id
# }

# Module for creating the gorilla repo and pushing to s3 bucket.
module "gorilla" {
  source            = "./modules/gorilla"
  resource_location = var.resource_location
  bucket            = aws_s3_bucket.cdqs_app_mgmt.bucket
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
    # Might not be necessary though, because automate module is an implicit dependency with this association explicitly set as a dep for that.
    aws_route_table_association.subnet_association
  ]
  node_setup_depends_on = [
    #The node setup implicitly depends on this resource, but it is mentioned here to avoid ambiguity.
    module.automate.automate_server_setup,
    # Set up node only after cookbook is available on the server.
    module.automate.setup_policy 
  ]
  iam_instance_profile_name    = module.iam.instance_profile_name
  bucket_name                  = var.bucket_name
  gorilla_binary_s3_object_key = module.gorilla.gorilla_binary_s3_object_key
  gorilla_repo_bucket_url      = "https://${aws_s3_bucket.cdqs_app_mgmt.bucket_domain_name}/gorilla-repository/"
}

# Create a keypair entry on console using the local keypair we created for AWS.
resource "aws_key_pair" "awskp" {
  key_name   = "awskp"
  public_key = file("./${var.public_key_path}")
  depends_on = [ aws_key_pair.awskp_mac ]
}

resource "aws_key_pair" "awskp_mac" {
  key_name   = "awskp_mac"
  public_key = file("./${var.macdhost_public_key_path}")
}

# Common bucket for gorilla and munki repositories.
resource "aws_s3_bucket" "cdqs_app_mgmt" {
  bucket = var.bucket_name
  acl    = "private"
}
