# Generate bash script for setting up chef repo
resource "local_file" "chef_repo_setup_script" {
  # Runs only on macOS
  count = local.isMacOS ? 1 : 0

  content = templatefile("${path.root}/../templates/chef_repo_setup_script.tpl", {
    cache_path        = abspath("${path.root}/../.cache")
    chef_repo_name    = var.chef_repo_name
    policy_group_name = var.policy_group_name
    policy_name       = var.policy_name
  })
  filename = "${path.root}/../.cache/chef_repo_setup_script"
}

# Configure and push the cookbook to server
resource "null_resource" "setup_policy_macos" {
  # Runs only on macOS
  count = local.isMacOS ? 1 : 0

  # Keep knife profile name as trigger since we want to access it inside the provisioner for this null resource.
  triggers = {
    knife_profile_name     = var.knife_profile_name
    chef_repo_setup_script = local_file.chef_repo_setup_script[count.index].filename
    chef_repo_name         = var.chef_repo_name
  }

  # Explicitly depend on automate and knife setup to preserve the logical order of execution.
  # Otherwise, terraform will try to run these resources in parallel and end up with an error.
  depends_on = [
    null_resource.extract_certs_macos,
    null_resource.automate_server_setup,
    local_file.knife_profile,
    local_file.chef_repo_setup_script
  ]

  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/knife_setup.sh.tpl", {
      knife_profile_name = var.knife_profile_name
      policy_group_name  = var.policy_group_name
      knife_profile      = abspath(local_file.knife_profile.filename)
    })
  }

  provisioner "local-exec" {
    command = self.triggers.chef_repo_setup_script
  }

  # When destroying the resource, remove the repository and knife profile from credentials.
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${self.triggers.chef_repo_setup_script}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${"${path.root}/../.cache/${self.triggers.chef_repo_name}"}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "sed -i '' \"/\\[${self.triggers.knife_profile_name}\\]/{N;N;N;d;}\" ~/.chef/credentials"
  }
}
