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

resource "aws_s3_bucket" "gorilla_repository" {
  bucket = "gorilla-repository"
  # Switch acl to authenticated-read?
  acl           = "private"
}

resource "aws_s3_bucket_object" "test" {
  for_each = fileset("${path.root}/../files/gorilla-repository", "**/*")

  bucket = aws_s3_bucket.gorilla_repository.bucket
  key    = each.value
  source = "${path.root}/../files/gorilla-repository/${each.value}"
}
