provider "aws" {
  region = var.region
}

terraform {
  required_version = "~= 1.7.1"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
