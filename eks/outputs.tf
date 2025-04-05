output "eks_cluster_id" {
  value       = aws_eks_cluster.this.id
  description = "EKS Cluster ID"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "EKS API Server endpoint"
}

output "eks_cluster_ca_data" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  description = "Certificate authority data for the cluster"
}

output "eks_node_group_id" {
  value       = aws_eks_node_group.this.id
  description = "EKS Node Group ID"
}
