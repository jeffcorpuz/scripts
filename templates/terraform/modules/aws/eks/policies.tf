###
# Account Wide IAM Policies
###
resource "aws_iam_policy" "load_balancer_controller" {
  name        = "AWSLoadBalancerController"
  policy      = file("${path.module}/templates/load_balancer_controller_policy.json")
  description = "AWS Load Balancer Controller Policy"
}
