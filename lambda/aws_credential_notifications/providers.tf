provider "aws" {
  region = var.region
}

terraform {
  required_version = "~= 1.6.6"
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}
