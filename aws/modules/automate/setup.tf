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
}
