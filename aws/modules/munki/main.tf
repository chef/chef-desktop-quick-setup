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

locals {
  all_files = fileset("${path.root}/../files/munki-repository", "**/*")
}

resource "aws_s3_bucket_object" "upload_munki_repository_content" {
  for_each = toset([ for item in local.all_files: item if !contains(split("/", item),".keep") ]) # Exclude .keep files.
  bucket   = var.bucket
  key      = "munki-repository/${each.value}"
  source   = "${path.root}/../files/munki-repository/${each.value}"
  # Make the repository contents publicly readable to allow access by munki client on the nodes.
  acl      = "public-read"
}
