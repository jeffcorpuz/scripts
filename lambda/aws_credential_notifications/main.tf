# This is required to get the AWS region via ${data.aws_region.current}.
data "aws_region" "current" {
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/files/lambda"
  output_path = "${path.module}/.terraform/archive_files/lambda.zip"
}

# Define a Lambda function.
#
# The handler is the name of the executable for go1.x runtime.
resource "aws_lambda_function" "main" {
  function_name = var.name
  description   = "Send AWS credential expiration notifications to Slack"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  handler          = "lambda"

  runtime     = "go2.x"
  memory_size = 128
  timeout     = 60 # in seconds

  role = aws_iam_role.main.arn

  tags = {
    Name        = var.name
    Application = var.application
  }

  environment {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

resource "aws_iam_role" "main" {
  name = "${var.name}-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
    
EOF

}

# Allow the Lambda function to send logs to CloudWatch
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role_policy" "logs" {
  name = "${var.name}-logs"
  role = aws_iam_role.main.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": [
    	"logs:CreateLogStream",
    	"logs:PutLogEvents"
    ],
    "Resource": [
    	"${aws_cloudwatch_log_group.main.arn}"
    ]
  }]
}
    
EOF

}

# Allow the Lambda function to send logs to CloudWatch
resource "aws_iam_role_policy" "main" {
  name = var.name
  role = aws_iam_role.main.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "Stmt1571938724768",
    "Action": [
    	"iam:GenerateCredentialReport",
    	"iam:GetAccountPasswordPolicy",
    	"iam:GetCredentialReport",
    	"iam:GetGroup",
    	"iam:ListUsers",
    	"iam:ListAccessKeys",
    	"iam:GetUser"
    ],
    "Effect": "Allow",
    "Resource": "*"
  }]
}
    
EOF

}

# Set-up Cloudwatch Event and Rules
# Example : Use for Cron/Rate jobs for AWS Lambda
resource "aws_cloudwatch_event_rule" "cw_rule" {
  name                = "${var.name} - Lambda Rule"
  description         = "cloudwatch event rule for aws credential notification"
  schedule_expression = var.schedule
}

resource "aws_cloudwatch_event_target" "cw_event_target" {
  rule      = aws_cloudwatch_event_rule.cw_rule.name
  target_id = var.name
  arn       = aws_lambda_function.main.arn
}

resource "aws_lambda_permission" "allow_cw_to_call_check" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cw_rule.arn
}
