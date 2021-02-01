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
| allow\_rdp | Security group ID for allow\_win\_rdp\_connection rule | `string` | n/a | yes |
| allow\_ssh | Security group ID for allow\_ssh rule | `string` | n/a | yes |
| chef\_server\_url | Public url of the automate server | `string` | n/a | yes |
| key\_name | Key name for AWS | `string` | n/a | yes |
| node\_count | Number of nodes | `number` | n/a | yes |
| node\_depends\_on | Resource dependencies for nodes. | `any` | `[]` | no |
| resource\_location | Region/Location for the resources | `string` | `"ap-south-1"` | no |
| subnet\_id | Subnet ID | `string` | n/a | yes |
| windows\_node\_instance\_type | n/a | `string` | `"t2.micro"` | no |

## Outputs

No output.

