output "source_bucket_arn" {
  value = aws_s3_bucket.source_bucket.arn
}

output "source_bucket_name" {
  value = aws_s3_bucket.source_bucket.bucket
}