# AWS terraform

## Requirements

| Name | Version |
|------|---------|
| terraform | 0.14.3 |
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_username | Admin username for automate server | `string` | n/a | yes |
| automate\_credentials | Automate server credentials configuration | <pre>object({<br>    user_name         = string<br>    user_display_name = string<br>    user_email        = string<br>    user_password     = string<br>    org_name          = string<br>    org_display_name  = string<br>    validator_path    = string<br>  })</pre> | n/a | yes |
| automate\_dns\_name\_label | Automate DNS name label | `string` | n/a | yes |
| availability\_zone | Availability zone for the resources | `string` | n/a | yes |
| private\_key\_path | Private key path (relative to terraform's path.root value) | `string` | `"/../keys/aws_terraform"` | no |
| public\_key\_path | Public key path (relative to terraform's path.root value) | `string` | `"/../keys/aws_terraform.pub"` | no |
| resource\_location | Region/Location for the resources | `string` | n/a | yes |

## Outputs

No output.

