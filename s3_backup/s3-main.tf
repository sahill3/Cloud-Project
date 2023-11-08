terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

resource "aws_s3_bucket" "backup_destination_bucket" {
    bucket = "cca-pbl"
    force_destroy = false
}

resource "aws_s3_bucket_ownership_controls" "backup_destination_bucket" {
    bucket = aws_s3_bucket.backup_destination_bucket.id
    rule{
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_public_access_block" "backup_destination_bucket" {
    bucket = aws_s3_bucket.backup_destination_bucket.id

    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "backup_destination_bucket" {
    depends_on = [ aws_s3_bucket_ownership_controls.backup_destination_bucket ,
    aws_s3_bucket_public_access_block.backup_destination_bucket]

    bucket = aws_s3_bucket.backup_destination_bucket.id
    acl = "public-read"    
}
