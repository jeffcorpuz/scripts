###
# Infrastructure related Helm charts installed during cluster creation
###
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}
###
# Istio Service Mesh
###
locals {
  # have to explicitly state these subnets due to only 1 subnet per az
  subnets_list   = tolist([data.aws_subnets.private-az1.ids[0], data.aws_subnets.private-az2.ids[0]])
  subnets_string = join("\\,", local.subnets_list)
}
###
# AWS Load Balancer Controller
###
resource "helm_release" "aws_load_balancer_controller" {
  count = var.deploy_helm_charts["aws_lb_controller"] == true ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.0"

  namespace = "kube-system"
  lint      = true

  values = [
    "${file("${path.module}/config/values/aws-lb-controller.yaml")}"
  ]

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
    type  = "string"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.lb_controller.arn
    type  = "string"
  }

  depends_on = [module.eks, module.eks_managed_node_group]
}
###
# metrics-server
###
resource "helm_release" "metrics_server" {
  count = var.deploy_helm_charts["metrics_server"] == true ? 1 : 0

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.11.0"

  namespace = "kube-system"
  lint      = true

  depends_on = [module.eks, module.eks_managed_node_group]
}
###
# external-secrets
###
resource "helm_release" "external_secrets" {
  count = var.deploy_helm_charts["external_secrets"] == true ? 1 : 0

  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.2"

  namespace        = "external-secrets"
  create_namespace = true
  lint             = true

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
    type  = "string"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets.arn
    type  = "string"
  }

  depends_on = [module.eks, module.eks_managed_node_group]
}
###
# cert-manager
###
resource "helm_release" "cert_manager" {
  count = var.deploy_helm_charts["cert_manager"] == true ? 1 : 0

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.13.1"

  namespace        = "cert-manager"
  create_namespace = true
  lint             = true

  set {
    name  = "installCRDs"
    value = "true"
    type  = "string"
  }

  depends_on = [module.eks, module.eks_managed_node_group]
}
###
# Prometheus Kube Stack (Prom Operator + Grafana)
###
resource "helm_release" "prometheus" {
  count = var.deploy_helm_charts["prometheus"] == true ? 1 : 0

  name       = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "56.0.3"
  namespace  = "monitoring"

  create_namespace = true
  lint             = true

  set {
    name  = "prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues"
    value = false
  }

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = false
  }

  set {
    name  = "prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues"
    value = false
  }

  set {
    name  = "prometheus.prometheusSpec.probeSelectorNilUsesHelmValues"
    value = false
  }

  depends_on = [module.eks, module.eks_managed_node_group]
}
###
# Istio Service Mesh
###
resource "helm_release" "istio_base" {
  count = var.deploy_helm_charts["istio"] == true ? 1 : 0

  name       = "base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.20.2"
  namespace  = "istio-system"

  create_namespace = true
  lint             = true

  depends_on = [module.eks, module.eks_managed_node_group, helm_release.aws_load_balancer_controller]
}

resource "helm_release" "istiod" {
  count = var.deploy_helm_charts["istio"] == true ? 1 : 0

  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.20.2"
  namespace  = "istio-system"

  lint = true

  depends_on = [module.eks, module.eks_managed_node_group, helm_release.istio_base]
}

resource "helm_release" "istio_gateway" {
  count = var.deploy_helm_charts["istio"] == true ? 1 : 0

  name       = "gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.20.2"
  namespace  = "istio-system"

  lint = true

  values = [
    "${file("${path.module}/config/values/istio-gateway.yaml")}"
  ]

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name"
    value = "${module.eks.cluster_name}-istio"
    type  = "string"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    value = local.subnets_string
    type  = "string"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-security-groups"
    value = aws_security_group.nlb.id
  }

  depends_on = [module.eks, module.eks_managed_node_group, helm_release.istiod]
}

resource "helm_release" "kiali_server" {
  count = var.deploy_helm_charts["istio"] == true ? 1 : 0

  name       = "kiali-server"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"
  version    = "1.79.0"
  namespace  = "istio-system"

  lint = true

  depends_on = [module.eks, module.eks_managed_node_group, helm_release.istiod]
}
