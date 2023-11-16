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
}

resource "aws_s3_bucket" "backup_bucket" {
    bucket = var.backup_bucket
}

resource "aws_s3_bucket_acl" "backup_bucket_acl" {
    bucket = aws_s3_bucket.backup_bucket.id
    acl    = "private"
}
