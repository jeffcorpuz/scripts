resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
}

terraform {
  backend "s3" {
    bucket         = var.s3_bucket_name
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform_locks"
  }
}
