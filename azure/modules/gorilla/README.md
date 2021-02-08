# azure.gorilla module
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
| resource\_group\_name | Resource group name | `string` | n/a | yes |
| resource\_location | Region/Location for the resources | `string` | `"southindia"` | no |
| storage\_account\_name | Storage account name | `string` | n/a | yes |
| subnet\_id | Subnet ID | `string` | n/a | yes |

## Outputs

No output.

