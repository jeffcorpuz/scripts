output "cluster_primary_security_group_id" {
  value       = module.eks.cluster_primary_security_group_id
  description = "The EKS Cluster Security Group ID"
}

output "node_security_group_id" {
  value       = module.eks.node_security_group_id
  description = "The EKS Node Security Group ID"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "The EKS Cluster Endpoint"
}

###
# IAM Roles for Service Accounts 
###
output "lb_controller_irsa_arn" {
  value       = aws_iam_role.lb_controller.arn
  description = "AWS Load Balancer IRSA ARN"
}

output "external_secrets_irsa_arn" {
  value       = aws_iam_role.external_secrets.arn
  description = "External Secrets IRSA ARN"
}

output "argocd_irsa_arn" {
  value       = one(aws_iam_role.argocd[*].arn)
  description = "ArgoCD IRSA ARN"
}
###
# NLB Security Group ID
###
output "nlb_security_group_id" {
  value = aws_security_group.nlb.id
}

output "nlb_security_group_arn" {
  value = aws_security_group.nlb.arn
}
