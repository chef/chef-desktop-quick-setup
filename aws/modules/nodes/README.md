# aws.nodes module

## Requirements

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_password | Administrator password for windows nodes | `string` | n/a | yes |
| allow\_rdp | Security group ID for allow\_win\_rdp\_connection rule | `string` | n/a | yes |
| allow\_ssh | Security group ID for allow\_ssh rule | `string` | n/a | yes |
| ami\_id | AMI ID for windows nodes | `string` | n/a | yes |
| chef\_server\_url | Public url of the automate server | `string` | n/a | yes |
| client\_name | Client name for validation | `string` | n/a | yes |
| gorilla\_binary\_s3\_object\_key | s3 bucket object key for gorilla binary | `string` | n/a | yes |
| gorilla\_repo\_bucket\_url | URL to gorilla repository/bucket | `string` | n/a | yes |
| gorilla\_s3\_bucket\_name | URL to gorilla repository/bucket | `string` | n/a | yes |
| iam\_instance\_profile\_name | S3 access IAM instance profile name | `string` | n/a | yes |
| key\_name | Key name for AWS | `string` | n/a | yes |
| node\_count | Number of nodes | `number` | n/a | yes |
| node\_depends\_on | Resource dependencies for nodes. | `any` | `[]` | no |
| node\_setup\_depends\_on | Resource dependencies for node setup. | `any` | `[]` | no |
| resource\_location | Region/Location for the resources | `string` | `"ap-south-1"` | no |
| subnet\_id | Subnet ID | `string` | n/a | yes |
| windows\_node\_instance\_type | n/a | `string` | `"t2.micro"` | no |

## Outputs

No output.

