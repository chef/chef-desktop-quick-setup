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
  isMacOS = substr(local.fullPathToModule, 0, 1) == "/"
}

resource "aws_instance" "node" {
  count                       = var.windows_node_count
  ami                         = var.windows_ami_id # Windows base server 2019 ami
  instance_type               = var.windows_node_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [
    var.allow_rdp,
    var.allow_winrm,
    var.allow_all_outgoing_requests
  ]
  subnet_id  = var.subnet_id
  key_name   = var.key_name
  depends_on = [var.node_depends_on]
  # Attach instance profile for s3 bucket access.
  iam_instance_profile = var.iam_instance_profile_name

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
    Name        = "cdqs-node-${count.index}"
  }

  # This script is part of the init-script that would be run while initializing the virtual node instances.
  # We set the password for administrator to be used for winrm connections and logging in through RDP clients.
  # We configure and set up the winrm service to allow all connections to the winrm ports and also to run automatically on subsequent restarts.
  user_data = <<EOF
    <powershell>
      # Set admin password.
      $admin = [adsi]("WinNT://./administrator, user")
      $admin.psbase.invoke("SetPassword", "${var.admin_password}")
      #  Configure winrm
      winrm quickconfig -q
      winrm set winrm/config '@{MaxTimeoutms="1800000"}'
      winrm set winrm/config/service '@{AllowUnencrypted="true"}'
      winrm set winrm/config/service/auth '@{Basic="true"}'
      winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
      # Allow winrm connection from anywhere in firewall
      netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
      # Stop the WinRM service, make sure it autostarts on reboot, and start it
      net stop winrm
      sc.exe config winrm start=auto
      net start winrm
    </powershell>
  EOF
}

# Create macOS instances on dedicated host
resource "aws_instance" "macos_node" {
  count                       = var.create_macos_nodes ? var.macos_node_count : 0
  ami                         = var.macos_ami_id
  instance_type               = "mac1.metal"
  host_id                     = var.macdhost_id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    var.allow_ssh,
    var.allow_rdp,
    var.allow_all_outgoing_requests
  ]
  subnet_id  = var.subnet_id
  key_name   = var.key_name
  depends_on = [var.node_depends_on, var.node_setup_depends_on]
  # Attach instance profile for s3 bucket access.
  iam_instance_profile = var.iam_instance_profile_name

  # macOS instances don't allow writing to /etc without root privileges. Asking the user to 
  # setup root privilages and then retry setup would not be desirable. Hence, we pass the
  # instructions for chef-client installation and setting up first-boot.json and client.rb
  # through user_data.
  user_data = templatefile("${path.root}/../templates/bash_user_data.tpl", {
    chef_server_url = var.chef_server_url
    node_name       = "macos-node"
    policy_group    = var.policy_group_name
    policy_name     = var.policy_name
  })

  # Since terraform doesn't provide a way to wait for the macOS instance to come online, 
  # we use the aws command-line with a max wait of 30mins (15-second interval checks). As
  # soon as the instance is ready to accept connections, this provisioner will complete
  # and the execution will move on to the next resource.
  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/ec2_status_check${local.isMacOS ? "" : ".ps1"}.tpl", {
      region      = var.resource_location
      instance_id = self.id
    })
    interpreter = local.isMacOS ? null : ["Powershell", "-Command"]
  }

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
    Name        = "cdqs-macos-node-${count.index}"
  }
}

resource "aws_instance" "linux_node" {
  count                       = var.linux_node_count
  ami                         = var.ubuntu_ami_id # ubuntu 18.04 ami
  instance_type               = var.windows_node_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [
    var.allow_rdp,
    var.allow_ssh,
    var.allow_all_outgoing_requests
  ]
  subnet_id  = var.subnet_id
  key_name   = var.key_name
  depends_on = [var.node_depends_on, var.node_setup_depends_on]
  # Attach instance profile for s3 bucket access.
  iam_instance_profile = var.iam_instance_profile_name

  user_data = templatefile("${path.root}/../templates/linux_user_data.tpl", {
    chef_server_url = var.chef_server_url
    node_name       = "ubuntu-node-${count.index}"
    policy_group    = var.policy_group_name
    policy_name     = var.policy_name
  })

  # Since terraform doesn't provide a way to wait for the instance to come online, 
  # we use the aws command-line with a max wait of 30mins (15-second interval checks). As
  # soon as the instance is ready to accept connections, this provisioner will complete
  # and the execution will move on to the next resource.
  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/ec2_status_check${local.isMacOS ? "" : ".ps1"}.tpl", {
      region      = var.resource_location
      instance_id = self.id
    })
    interpreter = local.isMacOS ? null : ["Powershell", "-Command"]
  }

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
    Name        = "cdqs-ubuntu-node-${count.index}"
  }
}
