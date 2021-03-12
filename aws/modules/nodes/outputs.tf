output "windows_nodes" {
  value = aws_instance.node
  description = "Windows nodes created by the module."
}

output "windows_node_eips" {
  value = aws_eip.node_eip
  description = "Elastic IPs for windows nodes"
}
