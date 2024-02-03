###
# Simple EKS setup with a new VPC with 1 public and 1 private subnet 
###
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  account_id  = data.aws_caller_identity.current.id
  account_arn = data.aws_caller_identity.current.arn

  oidc_issuer_url   = module.eks.cluster_oidc_issuer_url # full oidci url 
  oidc_provider     = module.eks.oidc_provider           # oidc issuer url w/out https://
  oidc_provider_arn = module.eks.oidc_provider_arn       # odic issuer arn
}
################################################################################
# Supporting Resources
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  enable_ipv6            = true
  create_egress_only_igw = true

  public_subnet_ipv6_prefixes                    = [0, 1, 2]
  public_subnet_assign_ipv6_address_on_creation  = true
  private_subnet_ipv6_prefixes                   = [3, 4, 5]
  private_subnet_assign_ipv6_address_on_creation = true
  intra_subnet_ipv6_prefixes                     = [6, 7, 8]
  intra_subnet_assign_ipv6_address_on_creation   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                           = 1,
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"                  = 1,
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
  }
}
################################################################################
# Kubernetes Cluster
################################################################################
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # IPV6
  cluster_ip_family          = "ipv6"
  create_cni_ipv6_iam_policy = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_security_group_name = "${var.cluster_name}-cluster-sg"
  node_security_group_name    = "${var.cluster_name}-node-sg"

  iam_role_name = "${var.cluster_name}-cluster-role"

  enable_cluster_creator_admin_permissions     = true
  enable_irsa                                  = true
  
  node_security_group_enable_recommended_rules = true
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }
}

###
# EKS Managed Node Group(s)
###
module "eks_managed_node_group" {
  for_each = { for ng in var.node_groups : ng.name => ng }
  source   = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

  cluster_name                      = module.eks.cluster_name
  cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
  vpc_security_group_ids            = [module.eks.node_security_group_id]
  subnet_ids                        = module.vpc.private_subnets
  create                            = true
  iam_role_attach_cni_policy        = true

  name           = "${var.cluster_name}-${each.value.name}"
  ami_type       = each.value.ami_type
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  desired_size   = each.value.desired_size
  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type

  tags   = merge(var.tags, each.value.tags)
  labels = merge(var.node_labels, each.value.labels)
}
