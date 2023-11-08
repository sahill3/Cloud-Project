terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "backup_lambda" {
    function_name = "backup-lambda"
    handler = "backup.handler"
    runtime = "nodejs14.x"
    role = aws_iam_role.lambda_execution_role.arn
    filename = "D:/VIIT/SEM 3/CCA/auto-backup/lambda_function/function.zip"
}
