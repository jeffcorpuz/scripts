###
# IAM Roles for Service Accounts Not Installed via AWS EKS Add Ons
###
###
# AWS Load Balancer Controller
###
data "aws_iam_policy" "lb_controller_policy" {
  name = "AWSLoadBalancerController"
}

data "aws_iam_policy_document" "lb_controller_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

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
        "system:serviceaccount:kube-system:aws-load-balancer-controller"
      ]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "lb_controller" {
  assume_role_policy = data.aws_iam_policy_document.lb_controller_trust_policy.json
  name               = "${var.cluster_name}-lb-controller-irsa"
}

resource "aws_iam_role_policy_attachment" "lb_controller_role_policy_attachment" {
  policy_arn = data.aws_iam_policy.lb_controller_policy.arn
  role       = aws_iam_role.lb_controller.name
}
###
# External Secrets Operator
###
data "aws_iam_policy_document" "external_secrets_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:Get*",
      "secretsmanager:Describe*",
      "secretsmanager:List*"
    ]
    resources = ["arn:aws:secretsmanager:${var.region}:${local.account_id}:secret:${var.cluster_name}*"]
  }
}

data "aws_iam_policy_document" "external_secrets_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

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
        "system:serviceaccount:external-secrets:external-secrets"
      ]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "external_secrets" {
  name        = "${var.cluster_name}-external-secrets-irsa"
  description = "Policy for ${var.cluster_name} External Secrets Service Account"

  policy = data.aws_iam_policy_document.external_secrets_policy.json
}

resource "aws_iam_role" "external_secrets" {
  assume_role_policy = data.aws_iam_policy_document.external_secrets_trust_policy.json
  name               = "${var.cluster_name}-external-secrets-irsa"
}

resource "aws_iam_role_policy_attachment" "external_secrets_role_policy_attachment" {
  policy_arn = aws_iam_policy.external_secrets.arn
  role       = aws_iam_role.external_secrets.name
}
###
# ArgoCD
###
data "aws_iam_policy_document" "argocd_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["arn:aws:iam::*:role/*-argocd*"]
  }
}

data "aws_iam_policy_document" "argocd_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

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
        "system:serviceaccount:argocd:*"
      ]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "argocd" {
  name        = "${var.cluster_name}-argocd-irsa"
  description = "Policy for ${var.cluster_name} ArgoCD Service Account"

  policy = one(data.aws_iam_policy_document.argocd_policy[*].json)
}

resource "aws_iam_role" "argocd" {
  assume_role_policy = data.aws_iam_policy_document.argocd_trust_policy.json
  name               = "${var.cluster_name}-argocd-irsa"
}

resource "aws_iam_role_policy_attachment" "argocd_role_policy_attachment" {
  policy_arn = aws_iam_policy.argocd.arn
  role       = aws_iam_role.argocd.name
}
###
# ArgoCD Image Updater
###
data "aws_iam_policy_document" "argocd_image_updater_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    resources = ["arn:aws:iam::*:role/*-argocd*"]
  }
}
data "aws_iam_policy_document" "argocd_image_updater_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

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
        "system:serviceaccount:argocd:argocd-image-updater"
      ]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "argocd_image_updater" {
  name        = "${var.cluster_name}-argocd-image-updater-irsa"
  description = "Policy for ${var.cluster_name} ArgoCD Image Updater Service Account"

  policy = data.aws_iam_policy_document.argocd_image_updater_policy.json
}

resource "aws_iam_role" "argocd_image_updater" {
  assume_role_policy = data.aws_iam_policy_document.argocd_image_updater_trust_policy.json
  name               = "${var.cluster_name}-argocd-image-updater-irsa"
}

resource "aws_iam_role_policy_attachment" "argocd_image_updater_role_policy_attachment" {
  policy_arn = aws_iam_policy.argocd_image_updater.arn
  role       = aws_iam_role.argocd_image_updater.name
}

resource "aws_iam_role_policy_attachment" "argocd_image_updater_managed_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.argocd_image_updater.name
}
###
# ExternalDNS
###
data "aws_iam_policy_document" "externaldns_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

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
        "system:serviceaccount:external-dns:external-dns"
      ]
    }

    principals {
      identifiers = [local.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "externaldns" {
  assume_role_policy = data.aws_iam_policy_document.externaldns_trust_policy.json
  name               = "${var.cluster_name}-externaldns-irsa"
}
