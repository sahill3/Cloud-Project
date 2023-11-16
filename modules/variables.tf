variable "aws_region"{
    description = "AWS Region"
    type = string
}

variable "source_bucket" {
    description = "AWS Source bucket name"
    type = string
}

variable "backup_bucket" {
    description = "AWS Backup bucket name"
    type = string
}