# azure.automate module

## Requirements

| Name | Version |
|------|---------|
| terraform | 0.14.6 |
| azurerm | >= 2.41.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 2.41.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password | Admin password for automate server | `string` | n/a | yes |
| admin\_username | Admin username for automate server | `string` | n/a | yes |
| automate\_credentials | Automate server credentials configuration | <pre>object({<br>    user_name          = string<br>    user_display_name  = string<br>    user_email         = string<br>    user_password      = string<br>    org_name           = string<br>    org_display_name   = string<br>    validator_path     = string<br>  })</pre> | n/a | yes |
| automate\_dns\_name\_label | Automate DNS name label | `string` | n/a | yes |
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| resource\_location | Region/Location for the resources | `string` | `"southindia"` | no |
| subnet\_id | Subnet ID | `string` | n/a | yes |

## Outputs

No output.

