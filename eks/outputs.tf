output "eks_cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
  description = "The name of the EKS cluster"
}

output "eks_cluster_arn" {
  value       = aws_eks_cluster.eks_cluster.arn
  description = "The ARN of the EKS cluster"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "The endpoint URL of the EKS cluster"
}

output "eks_node_group_name" {
  value       = aws_eks_node_group.eks_nodes.node_group_name
  description = "The name of the EKS node group"
}

output "eks_node_group_instance_types" {
  value       = aws_eks_node_group.eks_nodes.instance_types
  description = "The EC2 instance types used in the EKS node group"
}

output "referenced_eks_cluster_name" {
  value       = data.terraform_remote_state.eks.outputs.eks_cluster_name
  description = "The name of the referenced EKS cluster"
}
