# Outputs
output "cluster_name" {
  description = "EKS cluster Name"
  value       = aws_eks_cluster.dev_eks_cluster.name
}
output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.dev_eks_cluster.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.dev_eks_cluster.arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.dev_eks_cluster.endpoint
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = aws_eks_cluster.dev_eks_cluster.version
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster_sg.id
}

output "node_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = aws_security_group.eks_node_sg.id
}

output "oidc_issuer_url" {
  description = "The URL on the EKS cluster OIDC Issuer"
  value       = aws_eks_cluster.dev_eks_cluster.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for EKS"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.dev_eks_cluster.certificate_authority[0].data
}

output "node_groups" {
  description = "EKS node groups"
  value       = aws_eks_node_group.spot[*].node_group_name
}

# output "node_groups" {
#   description = "EKS node groups"
#   value       = aws_eks_node_group.main[*].node_group_name
# }

#0 odic endpoints
output "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN for the EKS cluster"
  value       = aws_iam_openid_connect_provider.oidc.arn
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = aws_iam_openid_connect_provider.oidc.url
}
