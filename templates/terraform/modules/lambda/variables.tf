variable "name" {
  type        = string
  description = "The name for the Lambda function"
  default     = "my-function"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1" 
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
  default     = "default"
}

variable "image_uri" {
  type        = string
  description = "image uri"
  default     = ""
}

variable "security_group_name" {
  type = string
  description = "security group name"
  default = "default"
}

variable "s3_bucket_name" {
  type        = string
  description = "which s3 bucket to store your state in"
  default     = ""
}