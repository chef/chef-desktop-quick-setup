output "gorilla_binary_s3_object_key" {
  value = aws_s3_bucket_object.upload_gorilla_binary.key
  description = "s3 bucket object key for gorilla binary"
}
output "gorilla_repo_bucket_url" {
  value = "https://${aws_s3_bucket.gorilla_repository.bucket_domain_name}/"
  description = "S3 bucket url"
}