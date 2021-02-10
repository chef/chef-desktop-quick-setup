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

  provisioner "remote-exec" {
    inline = ["/bin/bash ~/automate.setup.sh"]
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

resource "local_file" "knife_profile" {
  content = templatefile("${path.root}/../templates/knife_profile.tpl", {
    knife_profile_name = var.knife_profile_name
    client_name = var.automate_credentials.user_name
    automate_client_key_file = "${abspath(path.root)}/../keys/${var.automate_credentials.user_name}.pem"
    chef_server_url = "https://${aws_eip.eip.public_dns}/organizations/${var.automate_credentials.org_name}"
  })
  filename = "${path.root}/../files/knife_profile"
}

resource "null_resource" "setup_policy" {
  triggers = {
    knife_profile_name = var.knife_profile_name
  }
  depends_on = [ null_resource.automate_server_setup, local_file.knife_profile ]
  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/knife_setup.tpl", {
      knife_profile_name = var.knife_profile_name
      policy_name = var.policy_name
      knife_profile = abspath(local_file.knife_profile.filename)
    })
  }
  provisioner "local-exec" {
    when = destroy
    command = "sed -i '' \"/\\[${self.triggers.knife_profile_name}\\]/{N;N;N;d;}\" ~/.chef/credentials"
  }
}