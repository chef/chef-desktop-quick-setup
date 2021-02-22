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

  # Transfer certificates from the server to local directory. All keys can be found in PROJECT_ROOT/keys
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
  filename = "${path.root}/../files/knife_profile"
}

# Configure and push the cookbook to server
resource "null_resource" "setup_policy" {
  # Keep knife profile name as trigger since we want to access it inside the provisioner for this null resource.
  triggers = {
    knife_profile_name = var.knife_profile_name
  }
  # Explicitly depend on automate and knife setup to preserve the logical order of execution.
  # Otherwise, terraform will try to run these resources in parallel and end up with an error.
  depends_on = [ null_resource.automate_server_setup, local_file.knife_profile ]
  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/knife_setup.tpl", {
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