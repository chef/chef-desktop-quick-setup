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


# Network configuration for macos dedicated host

# # Create a private cloud.
# resource "aws_vpc" "macdhost_vpc" {
#   cidr_block           = "172.16.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = {
#     Environment = "Chef Desktop flow"
#     Team        = "Chef Desktop"
#   }
# }

# # Create an internet gateway.
# resource "aws_internet_gateway" "macdhost_vpc_gw" {
#   vpc_id = aws_vpc.macdhost_vpc.id
#   tags = {
#     Environment = "Chef Desktop flow"
#     Team        = "Chef Desktop"
#   }
# }

# # Create a public subnet.
# resource "aws_subnet" "macdhost_vpc_subnet" {
#   vpc_id     = aws_vpc.macdhost_vpc.id
#   cidr_block = "172.16.0.0/24"
#   availability_zone       = var.macdhost_availability_zone
#   map_public_ip_on_launch = true

#   tags = {
#     Environment = "Chef Desktop flow"
#     Team        = "Chef Desktop"
#   }
# }

# # Create route table and attach it to the internet gateway.
# resource "aws_route_table" "macdhost_vpc_rt" {
#   vpc_id = aws_vpc.macdhost_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.macdhost_vpc_gw.id
#   }
#   tags = {
#     Environment = "Chef Desktop flow"
#     Team        = "Chef Desktop"
#   }
# }

# # Associate route table with subnet.
# resource "aws_route_table_association" "macdhost_vpc_subnet_association" {
#   subnet_id      = aws_subnet.macdhost_vpc_subnet.id
#   route_table_id = aws_route_table.macdhost_vpc_rt.id
# }
