resource "null_resource" "windows_node_setup" {
  count = var.node_count
  depends_on = [var.node_setup_depends_on]

  triggers = {
    node_id = "${aws_instance.node[count.index].id}"
  }

  connection {
    type     = "winrm"
    host     = aws_eip.node_eip[count.index].public_dns
    port     = "5985"
    user     = "Administrator"
    password = var.admin_password
    timeout  = "15m"
  }

  # Install chef-client and configure it to connect to our server.
  # This might need to be changed in the future if we plan on upgrading to a newer Terraform version since it will be removed later.
  # Currently, this is marked deprecated but works fine.
  provisioner "chef" {
    client_options = ["chef_license 'accept'"]
    run_list       = ["desktop-config-lite::default"]
    node_name      = "windowsnode-${count.index}"
    server_url      = var.chef_server_url
    user_name       = var.client_name
    recreate_client = true
    user_key = file("${path.root}/../keys/${var.client_name}.pem")
    # Since we have a self signed cert on our chef server we are setting this to :verify_none
    # In production we should get a certificate and configure for the server and set this to :verify_peer
    ssl_verify_mode = ":verify_none"
  }
}

# Set up gorilla client by creating the gorilla config file on the node, then copy the gorilla client and run it to install packages mentioned in the catalog.
resource "null_resource" "gorilla_setup" {
  count = var.node_count
  depends_on = [ null_resource.windows_node_setup ]

  triggers = {
    node_id = "${aws_instance.node[count.index].id}"
  }

  connection {
    type     = "winrm"
    host     = aws_eip.node_eip[count.index].public_dns
    port     = "5985"
    user     = "Administrator"
    password = var.admin_password
    timeout  = "15m"
  }

  # Create the gorilla config in the default configuration path that gorilla expects.
  # Although we can configure gorilla to use a custom path, it was avoided for the sake of brevity.
  provisioner "file" {
    content = templatefile("${path.root}/../templates/gorilla.config.yaml.tpl", {
      gorilla_repo_bucket_url = var.gorilla_repo_bucket_url
    })
    destination = "C:\\ProgramData\\gorilla\\config.yaml"
  }

  # Copy the gorilla binary from s3 bucket and run it to install the applications specified in the catalog.
  provisioner "remote-exec" {
    inline = [
    "powershell Copy-S3Object -Bucket ${var.gorilla_s3_bucket_name} -Key ${var.gorilla_binary_s3_object_key} -LocalFile C:\\ProgramData\\gorilla\\gorilla.exe",
    "powershell C:\\ProgramData\\gorilla\\gorilla.exe"
    ]
  }
}