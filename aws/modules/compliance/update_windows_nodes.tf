/*
                      :-: File description :-:
The resource in this file handles setting up data_collector configuration
on windows nodes,thus depending on module.nodes by utilizing the output from that module.
The resource is also responsible for cleaning up the configuration if this resource
is destroyed, so that the nodes don't attempt to run the audit cookbook and fail to
report in the process. While leaving the configuration as it is may not trigger a client
run failure, it might result in duplicate entries in a later application of this module
on the same node, which might result in failure.
*/

# Read API token for compliance reporting.
data "local_file" "api_token" {
  depends_on = [
    null_resource.create_compliance_token
  ]
  filename = abspath("${path.root}/../keys/compliance-token")
}

/*
Localised connection configuration for each provisioner block: The resource has
connection blocks for each provisioner since destroy time provisioners access variables
only from the related resource and other provisioner access directly from the module's
scope. All values that need to accessed in destroy time provisioners are stored in
triggers as a map.

Provisioning script file and then running it instead of inline commands:
The powershell commands we execute through terraform are by default executed
in the cmd shell environment, thus properly escaping the command parameters
becomes quite cumbersome and in some cases it is near impossible.
Simplest alternative is to provision a powershell script, run it and then
remove it from the instance once it completes execution.
*/
resource "null_resource" "update_windows_nodes" {
  depends_on = [
    null_resource.update_chef_repo
  ]
  # Count is used as length of windows_node_setup so that the resource implicitly
  # depends on the node setup than the node/instance creation, which is a different action.
  # We would want to wait for the initial setup otherwise the two resources will
  # execute in parellel, resulting in a race condition which will result in an error.
  count      = length(var.windows_node_setup)

  triggers = {
    node_id = "${var.windows_nodes[count.index].id}"
    admin_password = var.admin_password
    server_dns = var.windows_node_eips[count.index].public_dns
  }

  # Configure data_collector url and token, then perform chef-client run.
  provisioner "file" {
    connection {
      type     = "winrm"
      host     = var.windows_node_eips[count.index].public_dns
      port     = "5985"
      user     = "Administrator"
      password = var.admin_password
      timeout  = "15m"
    }
    content = templatefile("${path.root}/../templates/compliance/configure_data_collector.ps1.tpl", {
      automate_server_url = var.automate_server_url
      api_token = chomp(data.local_file.api_token.content)
    })
    destination = "C:\\chef\\configure_data_collector.ps1"
  }

  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      host     = var.windows_node_eips[count.index].public_dns
      port     = "5985"
      user     = "Administrator"
      password = var.admin_password
      timeout  = "15m"
    }
    inline = [
      "powershell -ExecutionPolicy Bypass -File C:\\chef\\configure_data_collector.ps1",
      "powershell Remove-Item -Path C:\\chef\\configure_data_collector.ps1"
    ]
  }

  # Remove data collector configuration on destroy and run chef-client before exiting.
  provisioner "file" {
    when = destroy
    connection {
      type     = "winrm"
      host     = self.triggers.server_dns
      port     = "5985"
      user     = "Administrator"
      password = self.triggers.admin_password
      timeout  = "15m"
    }
    content = file("${path.root}/../templates/compliance/remove_data_collector_configuration.ps1.tpl")
    destination = "C:\\chef\\remove_data_collector_configuration.ps1"
  }
  provisioner "remote-exec" {
    when = destroy
    connection {
      type     = "winrm"
      host     = self.triggers.server_dns
      port     = "5985"
      user     = "Administrator"
      password = self.triggers.admin_password
      timeout  = "15m"
    }
    inline = [
      "powershell -ExecutionPolicy Bypass -File C:\\chef\\remove_data_collector_configuration.ps1",
      "powershell Remove-Item -Path C:\\chef\\remove_data_collector_configuration.ps1"
    ]
  }
}