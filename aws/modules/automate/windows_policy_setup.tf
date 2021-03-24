
# Configure and push the cookbook to server
resource "null_resource" "setup_policy_windows" {
  # Runs only on Windows.
  count = local.isMacOS ? 0 : 1

  # Explicitly depend on automate and knife setup to preserve the logical order of execution.
  # Otherwise, terraform will try to run these resources in parallel and end up with an error.
  depends_on = [ null_resource.automate_server_setup, local_file.knife_setup_script, local_file.knife_setup_cleanup, null_resource.extract_certs_windows ]

  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -File ${abspath("${path.root}/../.cache/knife_setup.ps1")}"
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
      policy_name = var.policy_name
      knife_profile = abspath(local_file.knife_profile.filename)
      cookbook_setup_script = abspath("${path.root}/../scripts/chef_setup.ps1")
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
