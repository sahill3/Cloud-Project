# Terraform Block
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
            }
    }
}

# Provider Block
provider "aws"{
    region = var.aws_region

    profile = "default"
}

resource "aws_s3_bucket" "backup_bucket" {
    bucket = var.backup_bucket
}

# resource "aws_s3_bucket_acl" "backup_bucket_acl" {
#     bucket = aws_s3_bucket.backup_bucket.id
#     acl    = "public-read"
# }

resource "aws_s3_bucket_public_access_block" "backup_bucket_acl" {
  bucket = aws_s3_bucket.backup_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "hosting_bucket_policy" {
    bucket = aws_s3_bucket.backup_bucket.id
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": ["s3:GetObject",
                            "s3:PutObject"],
                "Resource": "arn:aws:s3:::${var.backup_bucket}/*"
            }
        ]
    })
}

    acl    = "private"
}