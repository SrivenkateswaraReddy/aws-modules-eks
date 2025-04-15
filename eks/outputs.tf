output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = aws_eks_cluster.dev-eks-cluster.name
}

output "eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS cluster"
  value       = aws_eks_cluster.dev-eks-cluster.arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint for your Kubernetes API server"
  value       = aws_eks_cluster.dev-eks-cluster.endpoint
}

output "eks_cluster_kubeconfig" {
  description = "The kubeconfig for your EKS cluster. Configure your kubectl with this data to interact with your cluster. Note: This output might expose sensitive information."
  value       = aws_eks_cluster.dev-eks-cluster.kubeconfig
  sensitive   = true
}

output "eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster. Use this with the `server` attribute in your kubeconfig."
  value       = aws_eks_cluster.dev-eks-cluster.certificate_authority.0.data
}

output "eks_cluster_security_group_ids" {
  description = "A list of the security group IDs associated with the EKS cluster's VPC configuration."
  value       = aws_eks_cluster.dev-eks-cluster.vpc_config.0.security_group_ids
}

output "eks_node_security_group_id" {
  description = "The ID of the security group attached to the EKS nodes."
  value       = aws_security_group.eks_node_sg.id
}

output "eks_addon_vpc_cni_status" {
  description = "The status of the vpc-cni addon."
  value       = aws_eks_addon.example.status
}
