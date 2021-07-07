# Create a shell script to install munki client, configure and run munki client to install applications.
resource "null_resource" "munki_setup" {
  depends_on = [
    aws_s3_bucket_object.upload_munki_repository_content,
    var.munki_setup_depends_on
  ]

  count = length(var.macos_nodes)

  triggers = {
    node_id = "${var.macos_nodes[count.index].id}"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = var.macos_nodes[count.index].public_ip
    private_key = file("${path.root}/${var.private_key_path}")
  }
  # Create the munki client setup script.
  provisioner "file" {
    content = templatefile("${path.root}/../templates/munki.client.setup.sh.tpl", {
      munki_repo_url = "https://${var.bucket_domain_name}/munki-repository/"
    })
    destination = "~/munki.client.setup.sh"
  }

  # Run the munki client installation and configuration. Then run munki client to install applications.
  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/munki.client.setup.sh",
      "/bin/bash ~/munki.client.setup.sh"
    ]
  }
}
