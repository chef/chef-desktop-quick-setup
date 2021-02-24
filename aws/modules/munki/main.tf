terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.resource_location
}

resource "aws_s3_bucket_object" "upload_munki_repository_content" {
  for_each = fileset("${path.root}/../files/munki-repository", "**/*")
  bucket   = var.bucket
  key      = "munki-repository/${each.value}"
  source   = "${path.root}/../files/munki-repository/${each.value}"
  acl      = "public-read"
}
