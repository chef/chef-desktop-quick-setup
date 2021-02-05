
output "automate_server_url" {
  value = aws_eip.eip.public_dns
}

output "server_setup_task" {
  value = null_resource.automate_server_setup
}