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

resource "aws_s3_bucket" "source_bucket" {
    bucket = var.source_bucket
}

resource "aws_s3_bucket_acl" "source_bucket_acl" {
    bucket = aws_s3_bucket.source_bucket.id
    acl    = "public-read"
}

resource "aws_s3_bucket_policy" "hosting_bucket_policy" {
    bucket = aws_s3_bucket.source_bucket.id
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::${var.source_bucket}/*"
            }
        ]
    })
}

resource "aws_s3_bucket_versioning" "source_bucket_versioning" {
    bucket = aws_s3_bucket.source_bucket.id
    versioning_configuration {
        status = "Disabled"
    }
}

resource "aws_s3_bucket_website_configuration" "source_bucket_website_config" {
    bucket = aws_s3_bucket.source_bucket.id

    index_document {
        suffix = "index.html"
  }
}
