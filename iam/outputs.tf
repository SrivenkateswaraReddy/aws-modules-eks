output "eks_cluster_role_arn" {
  description = "The ARN of the EKS Cluster IAM role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_cluster_role_name" {
  description = "The name of the EKS Cluster IAM role"
  value       = aws_iam_role.eks_cluster_role.name
}

output "eks_cluster_policy_attachment_id" {
  description = "The ID of the policy attachment for the EKS Cluster role"
  value       = aws_iam_role_policy_attachment.eks_cluster_policy.id
}

output "eks_node_role_arn" {
  description = "The ARN of the EKS Node IAM role"
  value       = aws_iam_role.eks_node_role.arn
}

output "eks_node_role_name" {
  description = "The name of the EKS Node IAM role"
  value       = aws_iam_role.eks_node_role.name
}

output "node_worker_policy_attachment_id" {
  description = "The ID of the policy attachment for the EKS Node role (Worker Policy)"
  value       = aws_iam_role_policy_attachment.eks_worker_node_policy.id
}

output "node_cni_policy_attachment_id" {
  description = "The ID of the policy attachment for the EKS Node role (CNI Policy)"
  value       = aws_iam_role_policy_attachment.eks_cni_policy.id
}

output "node_ecr_policy_attachment_id" {
  description = "The ID of the policy attachment for the EKS Node role (ECR ReadOnly Policy)"
  value       = aws_iam_role_policy_attachment.eks_container_registry_policy.id
}
