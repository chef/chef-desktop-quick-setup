resource "null_resource" "macos_node_setup" {
  count      = var.create_macos_nodes ? var.macos_node_count : 0
  depends_on = [var.node_setup_depends_on]

  triggers = {
    node_id = "${aws_instance.macos_node[count.index].id}"
  }

  # Chef provisioner seems to be having an issue where it needs sudo access which ec2-user doesn't have, hence the provisioner fails.
  # Creating and exposing root user to run this provisioner successfully also makes the node vulnerable to potential security issues.
  # So we dump the provisioner and use plain knife bootstrap command. One caveat is we need to keep knife functionalities in check as new versions are released.
  provisioner "local-exec" {
    command = "knife bootstrap ${aws_eip.macos_node_eip[count.index].public_ip} -U ec2-user -i ${abspath(path.root)}/${var.private_key_path} -N macosnode-${count.index} --sudo -y"
  }
}
