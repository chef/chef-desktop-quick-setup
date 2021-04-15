
# Set up gorilla client by creating the gorilla config file on the node, then copy the gorilla client and run it to install packages mentioned in the catalog.
resource "null_resource" "gorilla_setup" {
  depends_on = [
    aws_s3_bucket_object.upload_repository_content,
    aws_s3_bucket_object.upload_gorilla_binary
  ]

  count      = length(var.windows_nodes)

  triggers = {
    node_id = "${var.windows_nodes[count.index].id}"
  }

  connection {
    type     = "winrm"
    host     = var.windows_node_eips[count.index].public_dns
    port     = "5985"
    user     = "Administrator"
    password = var.admin_password
    timeout  = "15m"
  }

  # Create the gorilla config in the default configuration path that gorilla expects.
  # Although we can configure gorilla to use a custom path, it was avoided for the sake of brevity.
  provisioner "file" {
    content = templatefile("${path.root}/../templates/gorilla.config.yaml.tpl", {
      gorilla_repo_bucket_url = "https://${var.bucket_domain_name}/gorilla-repository/"
    })
    destination = "C:\\ProgramData\\gorilla\\config.yaml"
  }

  # Copy the gorilla binary from s3 bucket and run it to install the applications specified in the catalog.
  provisioner "remote-exec" {
    inline = [
      "powershell Copy-S3Object -Bucket ${var.bucket} -Key ${aws_s3_bucket_object.upload_gorilla_binary.key} -LocalFile C:\\ProgramData\\gorilla\\gorilla.exe",
      "powershell C:\\ProgramData\\gorilla\\gorilla.exe"
    ]
  }
}
