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
