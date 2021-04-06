# Generate bash script for setting up chef repo
resource "local_file" "chef_repo_setup_script_windows" {
  # Runs only on macOS
  count = local.isMacOS ? 0 : 1

  content = templatefile("${path.root}/../templates/chef_repo_setup_script.ps1.tpl", {
    cache_path        = abspath("${path.root}/../.cache")
    chef_repo_name    = var.chef_repo_name
    policy_group_name = var.policy_group_name
    policy_name       = var.policy_name
  })
  filename = "${path.root}/../.cache/chef_repo_setup_script.ps1"
}

# Configure and push the cookbook to server
resource "null_resource" "setup_policy_windows" {
  # Runs only on Windows.
  count = local.isMacOS ? 0 : 1

  # Keep knife profile name as trigger since we want to access it inside the provisioner for this null resource.
  triggers = {
    knife_profile_name     = var.knife_profile_name
    chef_repo_setup_script = local_file.chef_repo_setup_script_windows[count.index].filename
    chef_repo_name         = var.chef_repo_name
  }

  # Explicitly depend on automate and knife setup to preserve the logical order of execution.
  # Otherwise, terraform will try to run these resources in parallel and end up with an error.
  depends_on = [
    null_resource.extract_certs_windows,
    null_resource.automate_server_setup,
    local_file.knife_profile,
    local_file.chef_repo_setup_script_windows,
    local_file.knife_setup_script,
    local_file.knife_setup_cleanup,
  ]

  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -File ${abspath("${path.root}/../.cache/knife_setup.ps1")}"
  }

  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -File ${self.triggers.chef_repo_setup_script}"
  }

  provisioner "local-exec" {
    when = destroy
    command = "rd /s /q ${path.root}\\..\\.cache\\${self.triggers.chef_repo_name}"
  }

  # When destroying the resource, remove the cookbook and knife profile from credentials.
  provisioner "local-exec" {
    when = destroy
    command = "powershell -ExecutionPolicy Bypass -File ${abspath("${path.root}/../.cache/knife_setup_cleanup.ps1")}"
  }
}

# Create a powershell script for knife setup
resource "local_file" "knife_setup_script" {
  # Runs only on Windows.
  count = local.isMacOS ? 0 : 1
  content = templatefile("${path.root}/../templates/knife_setup.ps1.tpl", {
      knife_profile_name = var.knife_profile_name
      policy_group_name = var.policy_group_name
      knife_profile = abspath(local_file.knife_profile.filename)
    })
  filename = "${path.root}/../.cache/knife_setup.ps1"
}

# Create a powershell script for clean up
resource "local_file" "knife_setup_cleanup" {
  # Runs only on Windows.
  count = local.isMacOS ? 0 : 1
  content = templatefile("${path.root}/../templates/knife_setup_cleanup.ps1.tpl", {
    profile_name = var.knife_profile_name
  })
  filename = "${path.root}/../.cache/knife_setup_cleanup.ps1"
}
