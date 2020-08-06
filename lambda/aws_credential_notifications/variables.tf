variable "name" {
  type        = string
  description = "The name for the Lambda function"
  default     = "aws-credentials-expiration-slack-notification"
}

variable "application" {
  type        = string
  description = "The application (for tagging the resources)"
  default     = "aws-credentials-expiration"
}

variable "slack_webhook_url" {
  type        = string
  description = "The webhook URL for the Slack integration"
  default     = ""
}

variable "schedule" {
  type        = "string"
  description = "CloudWatch Rate or Cron"
}

