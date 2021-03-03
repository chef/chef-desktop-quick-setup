
output "automate_server_url" {
  value = aws_eip.eip.public_dns
}

output "automate_server_setup" {
  value = null_resource.automate_server_setup
}

output "setup_policy" {
  value = [null_resource.setup_policy_macos, null_resource.setup_policy_windows]
}