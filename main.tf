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

    source = "./source_module"
    aws_region = "ap-south-1"
    source_bucket = "cca-pbl"
}

module "s3_backup_bucket" {
    source = "./backup_module"
    aws_region = "ap-south-1"
    backup_bucket = "cca-pbl-backup"

    source = ".source_module"
}

module "s3_backup_bucket" {
    source = ".backup_module"

}

