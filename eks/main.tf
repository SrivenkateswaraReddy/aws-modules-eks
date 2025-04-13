module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "20.35.0"
  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  authentication_mode            = var.authentication_mode
  vpc_id                         = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids                     = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  cluster_endpoint_public_access = true
  create_iam_role                = false
  iam_role_arn                   = data.terraform_remote_state.iam.outputs.eks_cluster_role_arn

  # cluster_compute_config = {
  #   enabled    = true
  #   node_pools = var.node_pools
  # }

  eks_managed_node_groups = {
    default = {
      name            = "default"
      instance_types  = ["c6g.large"]
      min_size        = 1
      max_size        = 3
      desired_size    = 1
      ami_type        = "AL2_ARM_64"
      iam_role_arn    = data.terraform_remote_state.iam.outputs.eks_node_role_arn
      create_iam_role = false
    }

    cluster_addons = {
      coredns                = {}
      eks-pod-identity-agent = {}
      kube-proxy             = {}
      vpc-cni                = {}
    }
    # bootstrap_self_managed_addons = true
  }
}

module "eks_aws_auth" {
  source     = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version    = "~> 20.0"
  depends_on = [module.eks]

  aws_auth_roles = [
    {
      rolearn  = data.terraform_remote_state.iam.outputs.eks_node_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
    {
      rolearn  = data.terraform_remote_state.iam.outputs.eks_cluster_role_arn
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  # aws_auth_users = [
  #   {
  #     userarn  = "arn:aws:iam::123456789012:user/my-admin-user"
  #     username = "my-admin-user"
  #     groups   = ["system:masters"]
  #   }
  # ]

  # aws_auth_accounts = [
  #   "123456789012"
  # ]
}
