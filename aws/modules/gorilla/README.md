# aws.gorilla module

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
| gorilla\_s3\_bucket\_name | Name of the bucket containing gorilla repository | `string` | n/a | yes |
| resource\_location | Region/Location for the resources | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| gorilla\_binary\_s3\_object\_key | s3 bucket object key for gorilla binary |
| gorilla\_repo\_bucket\_url | S3 bucket url |

