# These are exported primarily for tests since the terraform output command only reads from the root module.
output "automate_module_outputs" {
  value = module.automate
}

output "nodes_module_outputs" {
  value = module.nodes
  sensitive = true
}
