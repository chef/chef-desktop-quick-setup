/*
This module is responsible for setting up compliance configuration:
- Create an inspec profile inside the demo chef repo stored in .cache
- Create API token for compliance uploads and reporting.
- Authenticate user and upload profile to the server.
- Install audit cookbook and update the run list.
- Update node configurations (see update_windows_nodes.tf)
*/

locals {
  fullPathToModule = abspath("${path.module}/main.tf")
  isMacOS = substr(local.fullPathToModule, 0, 1) == "/"
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
resource "null_resource" "create_inspec_profile" {
  depends_on = [
    var.compliance_depends_on,
    local_file.inspec_yaml
  ]

  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/compliance/create_inspec_profile${local.isMacOS ? "" : ".ps1"}.tpl", {
      inspec_profile_name = var.inspec_profile_name
      repo_path           = abspath("${path.root}/../.cache/${var.chef_repo_name}")
    })
    interpreter = local.isMacOS ? null : ["Powershell", "-Command"]
  }
}

resource "null_resource" "delete_inspec_profile" {
  depends_on = [null_resource.create_inspec_profile]
  triggers = {
    inspec_profile_name = var.inspec_profile_name
    chef_repo_name = var.chef_repo_name
    isMacos = local.isMacOS
  }
  # Remove inspec profile from cache.
  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.isMacOS ? "rm -rf": "rd /s /q"} ${abspath("${path.root}/../.cache/${self.triggers.chef_repo_name}/${self.triggers.inspec_profile_name}")}"
  }
}

# Copy all controls to inspec profile
resource "null_resource" "copy_controls" {
  depends_on = [
    null_resource.create_inspec_profile
  ]
  for_each = local.all_controls
  triggers = {
    source_path = abspath("${path.root}/../files/compliance-controls/${each.value}")
    target_path = abspath("${path.root}/../.cache/${var.chef_repo_name}/${var.inspec_profile_name}/controls/${each.value}")
  }
  provisioner "local-exec" {
    command = "${local.isMacOS ? "cp" : "copy"} ${self.triggers.source_path} ${self.triggers.target_path}"
    interpreter = local.isMacOS ? null : ["Powershell", "-Command"]
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
}

resource "null_resource" "fetch_compliance_token" {
  depends_on = [
    null_resource.create_compliance_token
  ]

  provisioner "local-exec" {
    command = "${local.isMacOS ? "ssh -i \"${path.root}/${var.private_key_path}\"" : "plink -i ${path.root}/${var.private_ppk_key_path} -ssh"} ${var.admin_username}@${var.automate_server_public_ip} ${local.isMacOS ? "\"sudo cat ~/compliance-token\"" : "sudo cat ~/compliance-token"} > ${path.root}/../keys/compliance-token"
  }
}

# resource "null_resource" "clear_tokenfile_from_remote" {
#   depends_on = [
#     null_resource.fetch_compliance_token
#   ]
#   connection {
#     type        = "ssh"
#     user        = var.admin_username
#     host        = var.automate_server_url
#     private_key = file("${path.root}/${var.private_key_path}")
#   }

#   provisioner "remote-exec" {
#     inline = ["rm -f ~/compliance-token"]
#   }
# }

/*
Since adding this destroy provisioner to create_compliance_token resource forces
us to move the connection block inside its remote executioners, we separate it
from the resource and add this new resource as an explicit dependency to the next
resource execution in the order, null_resource.push_inspec_profile, thus making
sure that this resource is created whenever a profile is pushed with a newly created
token. Whenever the module is destroyed, this resource will also be destroyed with
it, thus running the destroy time provisioner which removes the api token from the
server.
*/
resource "null_resource" "delete_compliance_token" {
  depends_on = [
    null_resource.create_compliance_token,
  ]

  triggers = {
    isMacOS = local.isMacOS
    powershellCommand = "Invoke-WebRequest -Uri \"${var.automate_server_url}/apis/iam/v2/tokens/compliance-token\" -Method DELETE -DisableKeepAlive -Headers @{\"api-token\"=$(Get-Content ${abspath("${path.root}/../keys")}/compliance-token | Select-Object -First 1)}"
    bashCommand = "curl -s -H \"api-token: $(cat ${abspath("${path.root}/../keys")}/compliance-token)\" -H \"Connection: close\" -X \"DELETE\" https://${var.automate_server_url}/apis/iam/v2/tokens/compliance-token --insecure"
  }

  provisioner "local-exec" {
    when = destroy
    # command = self.triggers.isMacOS ? self.triggers.bashCommand : self.triggers.powershellCommand
    command = self.triggers.isMacOS ? self.triggers.bashCommand : "Write-Host \"Skipped compliance token deletion..\""
    interpreter = self.triggers.isMacOS ? null : ["Powershell", "-Command"]
  }
}

# Push inspec profile to automate server
resource "null_resource" "push_inspec_profile" {
  depends_on = [
    null_resource.copy_controls,
    null_resource.fetch_compliance_token,
    null_resource.delete_compliance_token
  ]
  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/compliance/push_inspec_profile.tpl", {
      inspec_profile_name = var.inspec_profile_name
      path_to_keys = abspath("${path.root}/../keys")
      automate_server_url = "https://${var.automate_server_url}"
      repo_path = abspath("${path.root}/../.cache/${var.chef_repo_name}")
    })
    interpreter = local.isMacOS ? null : ["Powershell", "-Command"]
  }
  # TODO: Should we try to remove the profile on destroy?
  # If we don't, while the command would error next time but won't stop the entire script from running.
  # So it would work fine. Otherwise, we have two solutions:
  # - Remove the profile via automate API (would require version as well)
  # - Always use overwrite flag on compliance upload.
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

  triggers = {
    chef_repo_name    = var.chef_repo_name
    policy_group_name = var.policy_group_name
    fileExtension = local.isMacOS ? "" : ".ps1"
    isMacOS = local.isMacOS
  }

  provisioner "local-exec" {
    command = templatefile("${path.root}/../templates/compliance/update_chef_repo${self.triggers.fileExtension}.tpl", {
      default_attributes_file = abspath(local_file.audit_attributes.filename)
      cache_path        = abspath("${path.root}/../.cache")
      chef_repo_name    = var.chef_repo_name
      policy_group_name = var.policy_group_name
    })
    interpreter = self.triggers.isMacOS ? null : ["Powershell", "-Command"]
  }

  # Remove audit cookbook, update policyfile and push policy to server.
  provisioner "local-exec" {
    when = destroy
    command = templatefile("${path.root}/../templates/compliance/remove_audit_cookbook${self.triggers.fileExtension}.tpl", {
      cache_path        = abspath("${path.root}/../.cache")
      chef_repo_name    = self.triggers.chef_repo_name
      policy_group_name = self.triggers.policy_group_name
    })
    interpreter = self.triggers.isMacOS ? null : ["Powershell", "-Command"]
  }
}
