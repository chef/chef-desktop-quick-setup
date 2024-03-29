output "automate_server_url" {
  value = aws_eip.eip.public_dns
}

output "automate_server_public_ip" {
  value = aws_eip.eip.public_ip
}

output "automate_server_setup" {
  value = null_resource.automate_server_setup
}

output "setup_policy" {
  value = [null_resource.setup_policy_macos, null_resource.setup_policy_windows]
}

output "automate_instance_id" {
  value = aws_instance.automate.id
}
