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
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "terraform_aws_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        }
      },
    ]
  })
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
    name = "aws_iam_policy_for_terraform_aws_lambda_role"
    path = "/"
    description = "IAM policy for the Lambda function"
    policy      = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:DeleteObject",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ],
      "Resource": [
        "${module.s3_source_bucket.source_bucket_arn}",
        "${module.s3_source_bucket.source_bucket_arn}/*",
        "${module.s3_backup_bucket.backup_bucket_arn}",
        "${module.s3_backup_bucket.backup_bucket_arn}/*",
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
    role = aws_iam_role.lambda_execution_role.name
    policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_python_code"{
    type = "zip"
    source_dir = "${path.module}/python/"
    output_path = "${path.module}/python/lambda.zip"
}

resource "aws_lambda_function" "backup_function" {
  function_name = "interval_backup"
  runtime       = "python3.8" 
  handler       = "lambda.lambda_handler"
  filename      = "${path.module}/python/lambda.zip" 
  role          = aws_iam_role.lambda_execution_role.arn
  source_code_hash = filebase64sha256("./python/lambda.zip")
  timeout = 30

  environment {
    variables = {
      SOURCE_BUCKET   = module.s3_source_bucket.source_bucket_name,
      BACKUP_BUCKET = module.s3_backup_bucket.backup_bucket_name,
    }
  }
}


resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "lambda_schedule"
  schedule_expression = "rate(10 minutes)"

  event_pattern = <<PATTERN
{
  "source": ["aws.s3"],
  "detail": {
    "eventName": ["PutObject", "DeleteObject"],
    "eventSource": ["s3.amazonaws.com"],
    "requestParameters": {
      "bucketName": ["${module.s3_source_bucket.source_bucket_name}"]
    }
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.backup_function.arn
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_function.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.lambda_schedule.arn
}