data "local_file" "validator_key" {
  depends_on = [var.node_setup_depends_on]
  filename = "${path.root}/../keys/validator.pem"
}

# The bootstrap run is decoupled from user_data and moved to this null_resource since we
# read validation.pem dynamically. Directly adding the content of validation.pem to user_data
# scripts would lead to the instance state updating on each terraform apply - forcing it to be
# destroyed and recreated. This is because dynamically loaded files with a dependency on a resource
# don't converge (internal terraform design, not a bug). Recreation would fail since mac1.metal
# dedicated hosts take quite some time (approx 1.5hrs currently) to become available again.
# By moving the validation.pem creation to a file provisioner block, we remove the "noise"
# from local_file content in user_data and persist the virtual node for a successful converge.
resource "null_resource" "macos_chef_setup" {
  count = length(aws_instance.macos_nodes) 
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.macos_nodes[count.index].public_ip
    private_key = file("${path.root}/${var.private_key_path}")
  }

  provisioner "file" {
    content = data.local_file.validator_key.content
    # We can't write to /etc through ec2-user, so instead the client.rb points to this location.
    destination = "~/validation.pem"
  }

  provisioner "file" {
    content = file("${path.root}/../scripts/macos_setup.sh")
    destination = "~/macos_setup.sh"
  }

  # Bootstrap the node with chef-client run and remove the validation.pem from node.
  provisioner "remote-exec" {
    inline = [ "/bin/bash ~/macos_setup.sh"]
  }
}
