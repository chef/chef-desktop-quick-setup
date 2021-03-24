resource "null_resource" "windows_node_setup" {
  count      = var.windows_node_count
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
    client_options  = ["chef_license 'accept'"]
    run_list        = ["desktop-config-lite::default"]
    use_policyfile  = true
    policy_group    = var.policy_group_name
    policy_name     = var.policy_name
    node_name       = "windowsnode-${count.index}"
    server_url      = var.chef_server_url
    user_name       = var.client_name
    recreate_client = true
    user_key        = file("${path.root}/../keys/${var.client_name}.pem")
    # Since we have a self signed cert on our chef server we are setting this to :verify_none
    # In production we should get a certificate and configure for the server and set this to :verify_peer
    ssl_verify_mode = ":verify_none"
  }
}
