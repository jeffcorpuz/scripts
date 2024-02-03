###############################
# EKS Add Ons
###############################
# TODO - Figure out how to do versioning
variable "eks_add_ons" {
  type = map(any)

  description = "Default versioning map based on cluster version"

  default = {
    "1.29" = {
      kubeproxy = "v1.29.0-eksbuild.2"
      coredns   = "v1.11.1-eksbuild.6"
      vpc_cni   = "v1.16.2-eksbuild.1"
      ebs_csi   = "v1.27.0-eksbuild.1"  
      efs_csi   = "v1.7.4-eksbuild.1"
    }
  }
}
###############################
# kube-proxy
###############################
resource "aws_eks_addon" "kubeproxy" {
  count         = var.deploy_eks_add_ons["kubeproxy"] == true ? 1 : 0
  addon_name    = "kube-proxy"
  addon_version = var.eks_add_ons[var.cluster_version]["kubeproxy"]
  cluster_name  = module.eks.cluster_name

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [module.eks]
}
###############################
# VPC CNI
###############################
resource "aws_eks_addon" "vpc_cni" {
  count         = var.deploy_eks_add_ons["vpc_cni"] == true ? 1 : 0
  addon_name    = "vpc-cni"
  addon_version = var.eks_add_ons[var.cluster_version]["vpc_cni"]
  cluster_name  = module.eks.cluster_name

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  service_account_role_arn = aws_iam_role.vpc_cni_role[0].arn

  depends_on = [module.eks]
}

data "aws_iam_policy_document" "vpc_cni_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values = [
        "system:serviceaccount:kube-system:aws-node"
      ]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "vpc_cni_role" {
  count              = var.deploy_eks_add_ons["vpc_cni"] == true ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_trust_policy.json
  name               = "${var.cluster_name}-vpc-cni-irsa"
}

resource "aws_iam_role_policy_attachment" "vpc_cni_role_policy_attachment" {
  count      = var.deploy_eks_add_ons["vpc_cni"] == true ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni_role[0].name
}
#################################
# CoreDNS
#################################
resource "aws_eks_addon" "coredns" {
  count         = var.deploy_eks_add_ons["coredns"] == true ? 1 : 0
  addon_name    = "coredns"
  addon_version = var.eks_add_ons[var.cluster_version]["coredns"]
  cluster_name  = module.eks.cluster_name

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  depends_on = [module.eks, aws_eks_addon.vpc_cni]

  timeouts {
    create = "30m"
    delete = "40m"
  }
}
#################################
# EBS CSI Driver
#################################
resource "aws_eks_addon" "ebs_csi" {
  count         = var.deploy_eks_add_ons["ebs_csi"] == true ? 1 : 0
  addon_name    = "aws-ebs-csi-driver"
  addon_version = var.eks_add_ons[var.cluster_version]["ebs_csi"]
  cluster_name  = module.eks.cluster_name

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  service_account_role_arn = aws_iam_role.ebs_csi_role[0].arn

  depends_on = [module.eks]
}

data "aws_iam_policy_document" "ebs_csi_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  count              = var.deploy_eks_add_ons["ebs_csi"] == true ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_trust_policy.json
  name               = "${var.cluster_name}-ebs-csi-irsa"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_role_policy_attachment" {
  count      = var.deploy_eks_add_ons["ebs_csi"] == true ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_role[0].name
}
#################################
# EFS CSI Driver
#################################
resource "aws_eks_addon" "efs_csi" {
  count         = var.deploy_eks_add_ons["efs_csi"] == true ? 1 : 0
  addon_name    = "aws-efs-csi-driver"
  addon_version = var.eks_add_ons[var.cluster_version]["efs_csi"]
  cluster_name  = module.eks.cluster_name

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  service_account_role_arn = aws_iam_role.efs_csi_role[0].arn

  depends_on = [module.eks]
}

data "aws_iam_policy_document" "efs_csi_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values = [
        "system:serviceaccount:kube-system:efs-csi-*"
      ]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "efs_csi_role" {
  count              = var.deploy_eks_add_ons["efs_csi"] == true ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.efs_csi_trust_policy.json
  name               = "${var.cluster_name}-efs-csi-irsa"
}

resource "aws_iam_role_policy_attachment" "efs_csi_role_policy_attachment" {
  count      = var.deploy_eks_add_ons["efs_csi"] == true ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_role[0].name
}
