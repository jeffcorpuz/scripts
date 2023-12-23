data "aws_vpc" "selected" {
    filter {
      name = "tag:Name"
      values = [var.vpc_name]
    }
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_security_group" "selected" {
  name = var.security_group_name
}


module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = var.name
  description   = "${var.name} lambda function"

  create_package = false

  image_uri    = var.image_uri
  package_type = "Image"

  vpc_subnet_ids         = data.aws_subnets.selected.ids
  vpc_security_group_ids = [data.aws_security_group.id]
  attach_network_policy = true
}
