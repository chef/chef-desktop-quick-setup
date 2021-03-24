locals {
  # Read all controls from files/compliance-controls
  all_controls = fileset("${path.root}/../files/compliance-controls", "**/*")
}

# Create inspec.yml for inspec profile
resource "local_file" "inspec_yaml" {
  content = templatefile("${path.root}/../templates/compliance/inspec.yml.tpl", {
    inspec_profile_name = var.inspec_profile_name
  })
  filename = "${path.root}/../.cache/inspec.yml"
}

# Generate inspec profile and overwrite inspec.yml contents
resource "null_resource" "create_inspec_profile_macos" {
  depends_on = [
    var.compliance_depends_on,
    local_file.inspec_yaml
  ]
  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/compliance/create_inspec_profile.tpl", {
      inspec_profile_name = var.inspec_profile_name
      repo_path           = abspath("${path.root}/../.cache/${var.chef_repo_name}")
    })
  }
}

# Copy all controls to inspec profile
resource "null_resource" "copy_controls_macos" {
  depends_on = [
    null_resource.create_inspec_profile_macos
  ]
  for_each = local.all_controls
  triggers = {
    source_path = abspath("${path.root}/../files/compliance-controls/${each.value}")
    target_path = abspath("${path.root}/../.cache/${var.chef_repo_name}/${var.inspec_profile_name}/controls/${each.value}")
  }
  provisioner "local-exec" {
    command = "cp ${self.triggers.source_path} ${self.triggers.target_path}"
  }
}

# Create a token to push inspec profile and run it on nodes.
resource "null_resource" "create_compliance_token" {
  depends_on = [
    var.compliance_depends_on
  ]
  connection {
    type        = "ssh"
    user        = var.admin_username
    host        = var.automate_server_url
    private_key = file("${path.root}/${var.private_key_path}")
  }

  provisioner "remote-exec" {
    inline = ["sudo chef-automate iam token create compliance-token --admin > ~/compliance-token"]
  }

  provisioner "local-exec" {
    command = "ssh -i \"${path.root}/${var.private_key_path}\" ${var.admin_username}@${var.automate_server_public_ip} \"cat ~/compliance-token\" > ${path.root}/../keys/compliance-token"
  }

  provisioner "remote-exec" {
    inline = ["rm -f ~/compliance-token"]
  }
}

# Push inspec profile to automate server
resource "null_resource" "push_inspec_profile" {
  depends_on = [
    null_resource.copy_controls_macos,
    null_resource.create_compliance_token,
  ]
  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/compliance/push_inspec_profile.tpl", {
      inspec_profile_name = var.inspec_profile_name
      path_to_keys = abspath("${path.root}/../keys")
      automate_server_url = "https://${var.automate_server_url}"
      repo_path = abspath("${path.root}/../.cache/${var.chef_repo_name}")
    })
  }
}

# Create default attributes file for audit cookbook.
resource "local_file" "audit_attributes" {
  content = templatefile("${path.root}/../templates/compliance/audit_default_attributes.rb.tpl", {
    inspec_profile_name = var.inspec_profile_name
  })
  filename = "${path.root}/../.cache/audit_default_attributes.rb"
}

# Update chef repo
resource "null_resource" "update_chef_repo" {
  depends_on = [
    local_file.audit_attributes,
    null_resource.push_inspec_profile,
  ]
  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/compliance/update_chef_repo.tpl", {
      default_attributes_file = abspath(local_file.audit_attributes.filename)
      cache_path        = abspath("${path.root}/../.cache")
      chef_repo_name    = var.chef_repo_name
      policy_group_name = var.policy_group_name
    })
  }
}
