locals {
  fullPathToModule = pathexpand("${path.module}/main.tf")
  isMacOS = substr(local.fullPathToModule, 0, 1) == "/"
}


resource "null_resource" "automate_server_setup" {
  triggers = {
    automate_instance_id = "${aws_instance.automate.id}"
  }

  connection {
    type        = "ssh"
    user        = var.admin_username
    host        = aws_eip.eip.public_dns
    private_key = file("${path.root}/${var.private_key_path}")
  }

  # Transfer the automate setup script to the instance's home directory.
  provisioner "file" {
    content = templatefile("${path.root}/../templates/automate.setup.sh.tpl", {
      user_name         = var.automate_credentials.user_name
      user_display_name = var.automate_credentials.user_display_name
      user_email        = var.automate_credentials.user_email
      user_password     = var.automate_credentials.user_password
      org_name          = var.automate_credentials.org_name
      org_display_name  = var.automate_credentials.org_display_name
      validator_path    = var.automate_credentials.validator_path
      fqdn              = aws_eip.eip.public_dns
    })
    destination = "~/automate.setup.sh"
  }

  # Run the setup script which would deploy automate 2 server.
  provisioner "remote-exec" {
    inline = ["/bin/bash ~/automate.setup.sh"]
  }

}

  # Transfer certificates from the server to local directory. All keys can be found in PROJECT_ROOT/keys
resource "null_resource" "extract_certs_windows" {
  # Runs only on Windows.
  count = local.isMacOS ? 0 : 1

  triggers = {
    trigger = null_resource.automate_server_setup.id
  }

  # The commands are split into multiple local executioners because passing multiple commands as we would for bash doesn't work here.
  # The first command is executed and the rest seems to be skipped.
  provisioner "local-exec" {
    # Piping input seems to be the only way currently to automate accepting connection to the host.
    # The PuTTY community doesn't recommend this for external servers in an automated script as it can potentially lead to a man in the middle attack.
    # But in this scenario we are sure that the host we are connecting to is our own server, and that the IP was not modified as it was passed directly from the output terraform generated.
    command = "echo y | pscp -P 22 -i ${path.root}/${var.private_ppk_key_path} ${var.admin_username}@${aws_eip.eip.public_ip}:/home/${var.admin_username}/${var.automate_credentials.user_name}.pem ${path.root}/../keys/${var.automate_credentials.user_name}.pem"
  }

  # Copy the validation key from server to local.
  provisioner "local-exec" {
    command = "pscp -P 22 -i ${path.root}/${var.private_ppk_key_path} ${var.admin_username}@${aws_eip.eip.public_ip}:/home/${var.admin_username}/validator.pem ${path.root}/../keys/validator.pem"
  }

  # Copy the automate credentials from the server to local.
  provisioner "local-exec" {
    command = "plink -ssh ${var.admin_username}@${aws_eip.eip.public_ip} -i ${path.root}/${var.private_ppk_key_path} sudo cat /home/ubuntu/automate-credentials.toml > ${path.root}/../keys/automate-credentials.toml"
  }
}

# Transfer certificates from the server to local directory. All keys can be found in PROJECT_ROOT/keys
resource "null_resource" "extract_certs_macos" {
  # Runs only on macOS
  count = local.isMacOS ? 1 : 0

  triggers = {
    trigger = null_resource.automate_server_setup.id
  }

  provisioner "local-exec"{
    command = "echo ${local.isMacOS}; echo ${aws_eip.eip.public_ip};"
  }

  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/extract_certs.sh.tpl", {
      user_name = var.admin_username
      ssh_key = "${path.root}/${var.private_key_path}"
      server_ip = aws_eip.eip.public_ip
      client_name = var.automate_credentials.user_name
      validator_path = var.automate_credentials.validator_path
      local_path = "${path.root}/../keys"
    })
  }
}


# Create a knife profile and add it to ~/.chef/credentials
resource "local_file" "knife_profile" {
  content = templatefile("${path.root}/../templates/knife_profile.tpl", {
    knife_profile_name = var.knife_profile_name
    client_name = var.automate_credentials.user_name
    automate_client_key_file = "${abspath(path.root)}/../keys/${var.automate_credentials.user_name}.pem"
    chef_server_url = "https://${aws_eip.eip.public_dns}/organizations/${var.automate_credentials.org_name}"
  })
  filename = "${path.root}/../.cache/knife_profile"
}

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
  depends_on = [ null_resource.automate_server_setup, local_file.knife_profile ]

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

# Configure and push the cookbook to server
resource "null_resource" "setup_policy_windows" {
  # Runs only on Windows.
  count = local.isMacOS ? 0 : 1

  # Explicitly depend on automate and knife setup to preserve the logical order of execution.
  # Otherwise, terraform will try to run these resources in parallel and end up with an error.
  depends_on = [ null_resource.automate_server_setup, local_file.knife_setup_script, local_file.knife_setup_cleanup ]

  provisioner "local-exec" {
    command = "powershell -ExecutionPolicy Bypass -File ${abspath("${path.root}/../.cache/knife_setup.ps1")}"
  }

  # When destroying the resource, remove the cookbook and knife profile from credentials.
  provisioner "local-exec" {
    when = destroy
    command = "powershell -ExecutionPolicy Bypass -File ${abspath("${path.root}/../.cache/knife_setup_cleanup.ps1")}"
  }
}