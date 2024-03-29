output "windows_nodes" {
  value = aws_instance.node
  description = "Windows nodes created by the module."
}

output "macos_nodes" {
  value = aws_instance.macos_node
  description = "macOS nodes created by the module."
  sensitive = true
}

output "linux_nodes" {
  value = aws_instance.linux_node
  description = "Linux nodes created by the module."
  sensitive = true
}

output "macos_chef_setup" {
  value = null_resource.macos_chef_setup
  description = "Null resource block with provisioners to bootstrap the node."
}

output "windows_node_setup" {
  value = null_resource.windows_node_setup
  description = "Chef client setup for windows nodes"
}

output "linux_node_setup" {
  value = null_resource.linux_node_setup
  description = "Chef client setup for linux nodes"
}
