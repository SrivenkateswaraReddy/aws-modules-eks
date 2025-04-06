resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = data.terraform_remote_state.iam.outputs.eks_cluster_role_arn

  vpc_config {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
  tags = merge(var.tags,
    {
      Name      = var.cluster_name
      ManagedBy = "terraform"
    }
  )
}

resource "aws_eks_node_group" "eks_nodes" {
  ami_type        = "AL2_x86_64" # Amazon Linux 2
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = data.terraform_remote_state.iam.outputs.eks_node_role_arn
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  instance_types  = [var.node_instance_type] # Ensure this is a single instance type

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  # remote_access {
  #   ec2_ssh_key               = "your-key"  # Replace with your SSH key name
  #   source_security_group_ids = [aws_security_group.eks_node_sg.id]
  # }



  tags = merge(var.tags,
    {
      Name      = var.node_group_name
      ManagedBy = "terraform"
    }
  )

  depends_on = [aws_eks_cluster.eks_cluster]
}
