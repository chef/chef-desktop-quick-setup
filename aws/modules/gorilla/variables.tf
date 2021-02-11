
variable "resource_location" {
  type        = string
  description = "Region/Location for the resources"
}

variable "gorilla_s3_bucket_name" {
  type = string
  description = "Name of the bucket containing gorilla repository"
}