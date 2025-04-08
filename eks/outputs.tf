output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "The security group ID for the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "node_group_iam_role_arn" {
  description = "The ARN of the IAM role for the node group"
  value       = local.eks_node_role_arn
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  description = "The base64-encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_kubeconfig" {
  description = "The kubeconfig for the EKS cluster"
  value       = module.eks.kubeconfig
}

output "cluster_kubeconfig_filename" {
  description = "The filename of the kubeconfig for the EKS cluster"
  value       = module.eks.kubeconfig_filename
}

output "cluster_kubeconfig_command" {
  description = "The command to update kubeconfig for the EKS cluster"
  value       = module.eks.kubeconfig_command
}

output "cluster_kubectl_commands" {
  description = "The kubectl commands for the EKS cluster"
  value       = module.eks.kubectl_commands
}

output "cluster_kubectl_commands_with_context" {
  description = "The kubectl commands with context for the EKS cluster"
  value       = module.eks.kubectl_commands_with_context
}
