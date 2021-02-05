resource "null_resource" "windows_node_setup" {
  depends_on = [var.node_setup_depends_on]
  triggers = {
    node_id = "${aws_instance.node.id}"
  }

  connection {
    type     = "winrm"
    host     = aws_eip.node_eip.public_dns
    port     = "5985"
    user     = "Administrator"
    password = var.admin_password
    timeout  = "15m"
  }

  provisioner "chef" {
    client_options = ["chef_license 'accept'"]
    run_list       = ["desktop-config-lite::default"]
    node_name      = "windowsnode"
    # secret_key      = file("../encrypted_data_bag_secret")
    server_url      = var.chef_server_url
    user_name       = var.client_name
    recreate_client = true
    # user_name       = "winuser"
    user_key = file("${path.root}/../keys/user.pem")
    # version         = "16.9.29"
    # Since we have a self signed cert on our chef server we are setting this to :verify_none
    # In production we should get a certificate and configure for the server and set this to :verify_peer
    ssl_verify_mode = ":verify_none"
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     ". { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install",
  #     "$env:PATH += ';C:\\opscode\\chef\\bin;C:\\opscode\\chef\\embedded\\bin;'"
  #   ]
  # }

  # provisioner "file" {
  #   content = templatefile("${path.root}/../templates/client.rb.tpl", {
  #     node_name       = "windows_node"
  #     user_name       = var.client_name
  #     chef_server_url = var.chef_server_url
  #   })
  #   destination = "C:\\chef\\client.rb"
  # }

  # Setup cookbook

  # Chef client first run.
  # provisioner "remote-exec" {
  #   inline = ["chef-client"]
  # }
}
