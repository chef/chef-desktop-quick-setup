  # Re create the default allow all egress rule.
resource "aws_security_group" "allow_all_outgoing_requests" {
  name        = "default_egress_allow_all-${random_string.iam_random_string.result}"
  description = "Default allow all outbound requests"
  vpc_id      = aws_vpc.vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  # Allow anyone to connect to port 22
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh-${random_string.iam_random_string.result}"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  # Allow http requests.
resource "aws_security_group" "allow_http" {
  name        = "allow_http-${random_string.iam_random_string.result}"
  description = "Allow HTTP requests"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  # Allow RDP client to connect to the instance.
resource "aws_security_group" "allow_rdp" {
  name        = "allow_win_rdp_connection-${random_string.iam_random_string.result}"
  description = "Allow RDP clients to connect"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "RDP"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

  # Allow WinRM connections to the instance.
resource "aws_security_group" "allow_winrm" {
  name        = "allow_winrm-${random_string.iam_random_string.result}"
  description = "Allow WinRM connections"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "WINRM"
    from_port   = 5985
    to_port     = 5986
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}