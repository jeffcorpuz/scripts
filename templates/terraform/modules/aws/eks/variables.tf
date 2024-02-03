variable "name" {
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
