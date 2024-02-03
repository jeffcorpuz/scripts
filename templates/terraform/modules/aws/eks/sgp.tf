###
# Security Group(s) and Rules for the Cluster NLB to be used by the Ingress Controller
###
###
# Security Group Configuration
###
resource "aws_security_group" "nlb" {
  name        = "${var.cluster_name}-nlb"
  description = "Security Group for the ${var.cluster_name} NLB"
  vpc_id      = data.aws_vpc.spoke_vpc.id

  tags = {
    Name = "${var.cluster_name}-nlb"
  }
}

# ingress from central alb to nlb allow all 
resource "aws_security_group_rule" "ingress_internet" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nlb.id

  description = "Allow all traffic from the public internet"
}

# ingress from account vpc cidr to nlb allow all
resource "aws_security_group_rule" "ingress_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [module.vpc.vpc_cidr_block]
  security_group_id = aws_security_group.nlb.id

  description = "Allow all traffic from ${var.vpc_name} VPC"
}

# egress all
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nlb.id

  description = "Allows all outbound traffic"
}

# ingress from nlb to k8s node allow all
resource "aws_security_group_rule" "ingress_node_nlb" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.nlb.id
  security_group_id        = module.eks.node_security_group_id

  description = "Allow all traffic from internal NLB"
}
