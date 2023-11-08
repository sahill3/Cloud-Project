terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = "ap-south-1"
}

resource "aws_cloudwatch_event_rule" "backup_rule" {
  name = "backup-schedule"
  schedule_expression = "rate(1 day)" 
}

module "s3_back_up"{
    source = ".//s3_backup"
}

module "lambda"{
    source = ".//lambda_function"
}