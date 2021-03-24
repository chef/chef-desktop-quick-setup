
# Configure and push the cookbook to server
resource "null_resource" "setup_policy_macos" {
  # Runs only on macOS
  count = local.isMacOS ? 1 : 0

  # Keep knife profile name as trigger since we want to access it inside the provisioner for this null resource.
  triggers = {
    knife_profile_name = var.knife_profile_name
  }

  # Explicitly depend on automate and knife setup to preserve the logical order of execution.
  # Otherwise, terraform will try to run these resources in parallel and end up with an error.
  depends_on = [ null_resource.extract_certs_macos, null_resource.automate_server_setup, local_file.knife_profile ]

  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/knife_setup.sh.tpl", {
      knife_profile_name = var.knife_profile_name
      policy_name = var.policy_name
      knife_profile = abspath(local_file.knife_profile.filename)
      cookbook_setup_script = abspath("${path.root}/../scripts/chef_setup")
    })
  }

  # When destroying the resource, remove the cookbook and knife profile from credentials.
  provisioner "local-exec" {
    when = destroy
    command = "rm -rf ~/.chef/cookbooks/desktop-config-lite"
  }
  provisioner "local-exec" {
    when = destroy
    command = "sed -i '' \"/\\[${self.triggers.knife_profile_name}\\]/{N;N;N;d;}\" ~/.chef/credentials"
  }
}
