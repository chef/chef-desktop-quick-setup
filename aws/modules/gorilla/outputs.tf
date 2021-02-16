output "gorilla_binary_s3_object_key" {
  value = aws_s3_bucket_object.upload_gorilla_binary.key
  description = "s3 bucket object key for gorilla binary"
}
