# aws.nodes module

## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| key\_name | Key name for AWS | `string` | n/a | yes |
| node\_count | Number of nodes | `number` | n/a | yes |
| resource\_location | Region/Location for the resources | `string` | `"ap-south-1"` | no |
| security\_group\_id | Security group ID | `string` | n/a | yes |
| subnet\_id | Subnet ID | `string` | n/a | yes |
| windows\_node\_instance\_type | n/a | `string` | `"t3.large"` | no |

## Outputs

No output.

