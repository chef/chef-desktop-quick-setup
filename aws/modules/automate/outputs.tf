
output "automate_server_url" {
  value = aws_eip.eip.public_dns
}
