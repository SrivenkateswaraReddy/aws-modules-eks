module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.35.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                                = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids                            = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  cluster_endpoint_public_access        = true
  create_iam_role                       = true
  iam_role_name                         = var.iam_role_name
  cluster_ip_family                     = var.cluster_ip_family
  iam_role_arn                          = local.eks_cluster_role_arn
  cluster_security_group_id             = aws_security_group.eks_cluster_sg.id
  cluster_additional_security_group_ids = [aws_security_group.eks_node_sg.id]


  cluster_compute_config = {
    enabled    = var.cluster_compute_config_enabled
    node_pools = var.cluster_node_pools
  }

  self_managed_node_groups = {
    default = {
      desired_size = var.node_group_desired_size
      max_size     = var.node_group_max_size
      min_size     = var.node_group_min_size

      instance_types = var.node_group_instance_types
      capacity_type  = var.node_group_capacity_type

    }
  }
  tags = merge(var.tags,
    {
      Name = "tfe_vpc"
    }
  )
}
