# Automate server AMI. Automatically uses the latest image for Ubuntu 18.04 bionic
data "aws_ami" "ubuntu_1804" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# AMI for Windows nodes. Automatically uses the latest image for Windows Server 2019
data "aws_ami" "windows_2019" {
  most_recent      = true
  owners           = ["801119661308"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# data "aws_ami" "macos_catalina" {
#   most_recent = true
#   owners = ["amazon"]
#   filter {
#     name = "name"
#     values = ["amzn-ec2-macos-10.15.7*"]
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