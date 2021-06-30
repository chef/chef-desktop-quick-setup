output "windows_nodes" {
  value = aws_instance.node
  description = "Windows nodes created by the module."
}

output "macos_nodes" {
  value = aws_instance.macos_node
  description = "Elastic IPs for macos nodes"
  sensitive = true
}

output "windows_node_setup" {
  value = null_resource.windows_node_setup
  description = "Chef client setup for windows node"
}
