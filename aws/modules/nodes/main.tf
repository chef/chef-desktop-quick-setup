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
  # count                       = var.node_count
  ami                         = var.ami_id # Windows base server 2019 ami
  instance_type               = var.windows_node_instance_type
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.allow_rdp]
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  depends_on                  = [var.node_depends_on]

  tags = {
    Environment = "Chef Desktop flow"
    Team        = "Chef Desktop"
    Name        = "cdqs-node"
  }

  connection {
    type     = "winrm"
    host     = self.public_ip
    port     = "5985"
    user     = "Administrator"
    password = "admin"
    timeout  = "15m"
    insecure = true
  }

  user_data = <<EOF
    <powershell>
      winrm quickconfig -q & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"} & winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'
      netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
      $admin = [adsi]("WinNT://./administrator, user")
      $admin.psbase.invoke("SetPassword", "admin")
    </powershell>
  EOF

  # provisioner "chef" {
  #   client_options = ["chef_license 'accept'"]
  #   run_list       = ["desktop-config-lite::default"]
  #   node_name      = "windowsnode"
  #   # secret_key      = file("../encrypted_data_bag_secret")
  #   server_url      = var.chef_server_url
  #   validation_client_name = var.client_name
  #   recreate_client = true
  #   user_name       = "winuser"
  #   user_key        = file("${path.root}/../keys/user.pem")
  #   # version         = "16.9.29"
  #   # Since we have a self signed cert on our chef server we are setting this to :verify_none
  #   # In production we should get a certificate and configure for the server and set this to :verify_peer
  #   ssl_verify_mode = ":verify_none"
  # }
}

resource "aws_eip" "node_eip" {
  # count = var.
  instance = aws_instance.node.id
  vpc      = true
}
