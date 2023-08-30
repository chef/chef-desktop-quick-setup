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
resource "null_resource" "update_linux_nodes" {
  depends_on = [
    null_resource.update_chef_repo,
    var.linux_node_setup
  ]
  # Count is used as length of linux_nodes so that the resource depends on
  # the node setup. We would want to wait for the initial setup otherwise
  # the two resources will execute in parellel, resulting in a race
  # condition which will result in an error.
  count = length(var.linux_nodes)

  triggers = {
    node_id    = "${var.linux_nodes[count.index].id}"
    server_ip = var.linux_nodes[count.index].public_ip
    private_key = file("${path.root}/${var.private_key_path}")
  }


  # Configure data_collector url and token, then perform chef-client run.
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = var.linux_nodes[count.index].public_ip
      private_key = file("${path.root}/${var.private_key_path}")
    }
    content = templatefile("${path.root}/../templates/compliance/configure_data_collector_linux.sh.tpl", {
      automate_server_url = var.automate_server_url
      api_token           = chomp(data.local_file.api_token.content)
    })
    destination = "/home/ubuntu/configure_data_collector.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = var.linux_nodes[count.index].public_ip
      private_key = file("${path.root}/${var.private_key_path}")
    }
    inline = [ "/bin/bash ~/configure_data_collector.sh", "rm ~/configure_data_collector.sh"]
  }

  # Remove data collector configuration on destroy and run chef-client before exiting.
  provisioner "file" {
    when = destroy
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.triggers.server_ip
      private_key = self.triggers.private_key
    }
    content     = file("${path.root}/../templates/compliance/remove_data_collector_configuration_linux.sh.tpl")
    destination = "/home/ubuntu/remove_data_collector_configuration.sh"
  }
  provisioner "remote-exec" {
    when = destroy
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.triggers.server_ip
      private_key = self.triggers.private_key
    }
    inline = ["/bin/bash ~/remove_data_collector_configuration.sh", "rm ~/remove_data_collector_configuration.sh"]
  }
}
