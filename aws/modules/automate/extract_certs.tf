
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
