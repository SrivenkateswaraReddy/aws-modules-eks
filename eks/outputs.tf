output "cluster_endpoint" {
  value       = aws_eks_cluster.dev-eks-cluster.cluster_id
  description = "cluster endpoint id"
}

output "eks_cluster_name" {
  value       = aws_eks_cluster.dev-eks-cluster.name
  description = "Name of the EKS cluster"
}

output "eks_cluster_role_arn" {
  value       = data.terraform_remote_state.iam.outputs.eks_cluster_role_arn
  description = "IAM role ARN for the EKS cluster"
}

output "eks_node_role_arn" {
  value       = data.terraform_remote_state.iam.outputs.eks_node_role_arn
  description = "IAM role ARN for the EKS nodes"
}

output "eks_private_subnet_ids" {
  value       = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  description = "Private subnet IDs for the EKS cluster"
}

output "eks_security_group_id" {
  value       = aws_security_group.eks_node_sg.id
  description = "Security group ID for EKS nodes"
}

output "eks_node_sg_name" {
  value       = aws_security_group.eks_node_sg.name
  description = "Name of the security group for EKS nodes"
}

output "eks_node_sg_ingress_ssh" {
  value = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  description = "Ingress rule for SSH access to EKS nodes"
}

output "eks_node_sg_ingress_https" {
  value = {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  description = "Ingress rule for HTTPS access to EKS nodes"
}

output "eks_node_sg_egress_all" {
  value = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  description = "Egress rule for all traffic from EKS nodes"
}
