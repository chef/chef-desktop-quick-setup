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
  source               = "./modules/automate"
  ami_id               = data.aws_ami.ubuntu_1804.id
  admin_username       = var.admin_username
  private_key_path     = var.private_key_path
  private_ppk_key_path = var.private_ppk_key_path
  resource_location    = var.resource_location
  subnet_id            = aws_subnet.subnet.id
  automate_credentials = var.automate_credentials
  security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http.id,
    aws_security_group.allow_all_outgoing_requests.id
  ]
  key_name                = aws_key_pair.awskp.key_name
  automate_dns_name_label = var.automate_dns_name_label
  automate_depends_on = [
    # Explicit dependency on the route table association with the subnet to make sure route tables are created when automate module is run.
    aws_route_table_association.subnet_association,
  ]
  knife_profile_name = var.knife_profile_name
  policy_group_name  = var.policy_group_name
  policy_name        = var.policy_name
  chef_repo_name     = var.chef_repo_name
}

module "compliance" {
  source                    = "./modules/compliance"
  automate_server_url       = module.automate.automate_server_url
  automate_server_public_ip = module.automate.automate_server_public_ip
  admin_username            = var.admin_username
  private_key_path          = var.private_key_path
  private_ppk_key_path      = var.private_ppk_key_path
  chef_repo_name            = var.chef_repo_name
  policy_group_name         = var.policy_group_name
  compliance_depends_on = [
    module.automate.automate_server_setup,
    module.automate.setup_policy
  ]
  windows_nodes      = module.nodes.windows_nodes
  windows_node_eips  = module.nodes.windows_node_eips
  macos_node_eips    = module.nodes.macos_node_eips
  windows_node_setup = module.nodes.windows_node_setup
  admin_password     = var.admin_password_win_node
}

# Set up IAM profile to provide access to s3 bucket from virtual nodes.
module "iam" {
  source = "./modules/iam"
}

# Module for creating the munki repo and pushing to s3 bucket.
module "munki" {
  source             = "./modules/munki"
  bucket             = aws_s3_bucket.cdqs_app_mgmt.bucket
  bucket_domain_name = aws_s3_bucket.cdqs_app_mgmt.bucket_domain_name
  resource_location  = var.resource_location
  macos_node_eips    = module.nodes.macos_node_eips
  private_key_path   = var.private_key_path
}

# Module for creating the gorilla repo and pushing to s3 bucket.
module "gorilla" {
  source             = "./modules/gorilla"
  resource_location  = var.resource_location
  bucket             = aws_s3_bucket.cdqs_app_mgmt.bucket
  bucket_domain_name = aws_s3_bucket.cdqs_app_mgmt.bucket_domain_name
  windows_nodes      = module.nodes.windows_nodes
  windows_node_eips  = module.nodes.windows_node_eips
  admin_password     = var.admin_password_win_node
}

# Module for creating virtual nodes.
module "nodes" {
  source                      = "./modules/nodes"
  windows_ami_id              = data.aws_ami.windows_2019.id
  macos_ami_id                = data.aws_ami.macos_catalina.id
  admin_password              = var.admin_password_win_node
  resource_location           = var.resource_location
  subnet_id                   = aws_subnet.subnet.id
  allow_ssh                   = aws_security_group.allow_ssh.id
  allow_rdp                   = aws_security_group.allow_rdp.id
  allow_winrm                 = aws_security_group.allow_winrm.id
  allow_all_outgoing_requests = aws_security_group.allow_all_outgoing_requests.id
  key_name                    = aws_key_pair.awskp.key_name
  chef_server_url             = "https://${module.automate.automate_server_url}/organizations/${var.automate_credentials.org_name}"
  client_name                 = var.automate_credentials.user_name
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
  iam_instance_profile_name = module.iam.instance_profile_name
  bucket_name               = var.bucket_name
  munki_repo_bucket_url     = "https://${aws_s3_bucket.cdqs_app_mgmt.bucket_domain_name}/munki-repository"
  macdhost_id               = var.macdhost_id
  create_macos_nodes        = var.create_macos_nodes
  policy_group_name         = var.policy_group_name
  policy_name               = var.policy_name
}

# Create a keypair entry on console using the local keypair we created for AWS.
resource "aws_key_pair" "awskp" {
  key_name   = "awskp"
  public_key = file("./${var.public_key_path}")
}

# Common bucket for gorilla and munki repositories.
resource "aws_s3_bucket" "cdqs_app_mgmt" {
  bucket = var.bucket_name
  acl    = "private"
}
