output "backup_bucket_arn" {
  value = aws_s3_bucket.backup_bucket.arn
}

output "backup_bucket_name" {
  value = aws_s3_bucket.backup_bucket.bucket
}