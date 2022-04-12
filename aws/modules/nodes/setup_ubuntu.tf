resource "null_resource" "linux_node_setup" {
  count      = var.linux_node_count
  depends_on = [var.node_setup_depends_on]

  triggers = {
    node_id = "${aws_instance.linux_node[count.index].id}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_instance.linux_node[count.index].public_ip
    private_key = file("${path.root}/${var.private_key_path}")
  }


  provisioner "file" {
    content = data.local_file.validator_key.content
    # We can't write to /etc through ec2-user, so instead the client.rb points to this location.
    destination = "~/validation.pem"
  }

  provisioner "file" {
    content = file("${path.root}/../scripts/linux_setup.sh")
    destination = "~/linux_setup.sh"
  }

  # Bootstrap the node with chef-client run and remove the validation.pem from node.
  provisioner "remote-exec" {
    inline = [ "/bin/bash ~/linux_setup.sh"]
  }
}
