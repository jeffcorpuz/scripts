resource "aws_iam_role" "this" {
  name = "wholesomify_iam"

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
  function_name = "wholesomify"
  role          = "${aws_iam_role.this.arn}"
  handler       = "lambda"

  filename      = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  runtime     = "python3.11"
  memory_size = 128
  timeout     = 120 # in seconds

  # comment if you want to use this instead of dotenv
  # environment {
  #   variables = {
  #     REDDITNAME = "blank",
  #     PASSWORD   = "blank",
  #     APPID      = "blank",
  #     SECRET     = "blank",
  #     APPNAME    = "blank",
  #     LIMIT      = "blank"
  #   }
  # }
}
