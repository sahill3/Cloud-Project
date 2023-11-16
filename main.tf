# Terraform Block
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"
            }
    }
}

module "s3_source_bucket" {
    source = ".source_module"
}

module "s3_backup_bucket" {
    source = ".backup_module"
}

