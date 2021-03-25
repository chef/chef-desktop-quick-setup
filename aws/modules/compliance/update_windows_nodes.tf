data "local_file" "api_token" {
  filename = abspath("${path.root}/../keys/compliance-token")
}

resource "null_resource" "update_windows_nodes" {
  depends_on = [
    null_resource.update_chef_repo
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

  provisioner "file" {
    content = templatefile("${path.root}/../templates/compliance/configure_data_collector.ps1.tpl", {
      automate_server_url = var.automate_server_url
      api_token = chomp(data.local_file.api_token.content)
    })
    destination = "C:\\chef\\configure_data_collector.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell -ExecutionPolicy Bypass -File C:\\chef\\configure_data_collector.ps1",
      "powershell Remove-Item -Path C:\\chef\\configure_data_collector.ps1"
    ]
  }
}