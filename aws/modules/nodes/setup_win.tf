resource "null_resource" "windows_node_setup" {
  triggers = {
    node_id = "${aws_instance.node.id}"
  }

  connection {
    type     = "winrm"
    host     = aws_eip.node_eip.public_ip
    port     = "5985"
    user     = "Administrator"
    password = "admin"
    timeout  = "15m"
    insecure = true
  }

  provisioner "remote-exec" {
    inline = [
      " . { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install",
      "$env:PATH += ';C:\\opscode\\chef\\bin;C:\\opscode\\chef\\embedded\\bin;'"
    ]
  }

  provisioner "file" {
    content     = templatefile("${path.root}/../templates/client.rb.tpl", {
      node_name = "windows_node"
      user_name = var.client_name
      chef_server_url = var.chef_server_url
    })
    destination = "C:\\chef\\client.rb"
  }

  # Setup cookbook

  # Chef client first run.
  # provisioner "remote-exec" {
  #   inline = ["chef-client"]
  # }
}
