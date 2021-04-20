output "windows_nodes" {
  value = aws_instance.node
  description = "Windows nodes created by the module."
}

output "windows_node_eips" {
  value = aws_eip.node_eip
  description = "Elastic IPs for windows nodes"
}

output "macos_node_eips" {
  value = aws_eip.macos_node_eip
  description = "Elastic IPs for macos nodes"
}

output "windows_node_setup" {
  value = null_resource.windows_node_setup
  description = "Chef client setup for windows node"
}
