variable "vpc_name" {
  type        = string
  description = "The name for the VPC"
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = "The name for the Kubernetes Cluster"
  default     = ""
}

variable "cluster_version" {
  type        = string
  description = "The default version for the Kubernetes Cluster"
  default     = "1.29"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-2"
}

variable "deploy_eks_add_ons" {
  description = "Deploy AWS EKS Add Ons"
  type        = map(bool)

  default = {
    kubeproxy = true
    coredns   = true
    vpc_cni   = true
    ebs_csi   = false
    efs_csi   = false
  }
}

variable "deploy_helm_charts" {
  description = "Deploy Helm Charts in TF Repo"
  type        = map(bool)

  default = {
    istio             = true
    aws_lb_controller = true
    metrics_server    = true
    external_secrets  = true
    cert_manager      = true
    prometheus        = true
  }
}

variable "node_groups" {
  type = set(object({
    name           = string
    ami_type       = string
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
    tags           = optional(map(string), {})
    labels         = optional(map(string), {})
  }))

  description = "node group(s) for the kubernetes cluster"
  default = [{
    name           = "default"
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.medium"]
    capacity_type  = "SPOT"
    min_size       = 2
    max_size       = 2
    desired_size   = 2
  }]

  nullable = false
}
