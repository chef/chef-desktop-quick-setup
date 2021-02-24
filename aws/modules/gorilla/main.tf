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
  all_files = fileset("${path.root}/../files/gorilla-repository", "**/*")
}

resource "aws_s3_bucket_object" "upload_repository_content" {
  for_each = toset([ for item in local.all_files: item if !contains(split("/", item),".keep") ]) # Exclude .keep files.
  bucket   = var.bucket
  key      = "gorilla-repository/${each.value}"
  source   = "${path.root}/../files/gorilla-repository/${each.value}"
  # Make the repository contents publicly readable to allow access by gorilla client on the nodes.
  acl      = "public-read"
}

# This s3 object is private by default since virtual nodes access it via Copy-S3Object class which will make use of the attached IAM instance profile.
resource "aws_s3_bucket_object" "upload_gorilla_binary" {
  source = "${path.root}/../files/gorilla-1.0.0.5.exe"
  bucket = var.bucket
  key    = "gorilla-1.0.0.5.exe"
}
