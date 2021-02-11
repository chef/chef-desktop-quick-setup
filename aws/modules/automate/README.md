# aws.automate module

## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| local | n/a |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_username | Admin username for automate server | `string` | n/a | yes |
| ami\_id | AMI ID for automate server | `string` | n/a | yes |
| automate\_credentials | Automate server credentials configuration | <pre>object({<br>    user_name         = string<br>    user_display_name = string<br>    user_email        = string<br>    user_password     = string<br>    org_name          = string<br>    org_display_name  = string<br>    validator_path    = string<br>  })</pre> | n/a | yes |
| automate\_depends\_on | Resource dependencies for automate server. | `any` | `[]` | no |
| automate\_dns\_name\_label | Automate DNS name label | `string` | n/a | yes |
| key\_name | Key name for AWS | `string` | n/a | yes |
| knife\_profile\_name | Name of the profile for the server | `string` | `"cdqs-profile"` | no |
| policy\_name | Name of the policy to create on server | `string` | `"cdqs-policy"` | no |
| private\_key\_path | Private key path | `string` | `"../keys/aws_terraform"` | no |
| resource\_location | Region/Location for the resources | `string` | `"ap-south-1"` | no |
| security\_group\_id | Security group ID | `string` | n/a | yes |
| subnet\_id | Subnet ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| automate\_server\_setup | n/a |
| automate\_server\_url | n/a |
| setup\_policy | n/a |

