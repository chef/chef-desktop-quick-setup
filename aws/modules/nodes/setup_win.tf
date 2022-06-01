resource "null_resource" "windows_node_setup" {
  count      = var.windows_node_count
  depends_on = [var.node_setup_depends_on]

  triggers = {
    node_id = "${aws_instance.node[count.index].id}"
  }

  connection {
    type     = "winrm"
    host     = aws_instance.node[count.index].public_ip
    port     = "5985"
    user     = "Administrator"
    password = var.admin_password
    timeout  = "15m"
  }

  provisioner "file" {
    content     = data.local_file.validator_key.content
    destination = "C:/chef/validation.pem"
  }

  provisioner "file" {
    content = templatefile("${path.root}/../templates/win_setup.ps1.tpl", {
      chef_server_url = var.chef_server_url
      node_name       = "windowsnode-${count.index}"
      policy_name     = var.policy_name
      policy_group    = var.policy_group_name
    })
    destination = "C:/win_setup.ps1"
  }

  # Installs chef client and create first-boot.json and client.rb
  provisioner "remote-exec" {
    inline = [
      "powershell -ExecutionPolicy Bypass -File C:/win_setup.ps1",
      "powershell Remove-Item -Path C:/win_setup.ps1"
    ]
  }

  # Bootstrap the node with chef-client run and remove the validation.pem from node.
  provisioner "remote-exec" {
    inline = [
      "powershell chef-client -j C:/chef/first-boot.json",
      "powershell Remove-Item -Path C:/chef/validation.pem"
    ]
  }
}
