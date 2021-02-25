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
  count                       = var.windows_node_count
  ami                         = var.windows_ami_id # Windows base server 2019 ami
  instance_type               = var.windows_node_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.allow_rdp]
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  depends_on                  = [var.node_depends_on]
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
  vpc_security_group_ids      = [var.allow_ssh]
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  depends_on                  = [var.node_depends_on]
  # Attach instance profile for s3 bucket access.
  iam_instance_profile = var.iam_instance_profile_name

  # macOS instances are taking quite a bit of time to allow ssh into the systems after their creation
  # to run scripts. So we can pass the scripts for node bootstrapping, chef client run, munki client
  # configuration and run on user_data. This seems to be the only graceful way of doing this at this time.
  user_data = templatefile("${path.root}/../templates/macos.setup.tpl", {
    chef_server_url = var.chef_server_url
    node_name       = "macosnode-${count.index}"
    munki_repo_url  = var.munki_repo_bucket_url
    validator_key   = file("${path.root}/../keys/validator.pem")
  })

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
    Name        = "cdqs-macos-node-${count.index}"
  }
}

resource "aws_eip" "node_eip" {
  count    = var.windows_node_count
  instance = aws_instance.node[count.index].id
  vpc      = true
}

resource "aws_eip" "macos_node_eip" {
  count    = var.create_macos_nodes ? var.macos_node_count : 0
  instance = aws_instance.macos_node[count.index].id
  vpc      = true
}
