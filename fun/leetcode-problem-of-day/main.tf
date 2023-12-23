resource "aws_iam_role" "this" {
  name = "leetcode_bot_iam"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/files/"
  output_path = "${path.module}/.terraform/archive_files/lambda.zip"
}

resource "aws_lambda_function" "this" {
  function_name = "leetcode-bot"
  role          = "${aws_iam_role.this.arn}"
  handler       = "lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  runtime     = "python3.11"
  memory_size = 128
  timeout     = 120 # in seconds
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "daily_lambda_trigger"
  description         = "Trigger Lambda function daily"
  schedule_expression = "cron(0 12 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.daily_trigger.name
  arn  = aws_lambda_function.this.arn
}