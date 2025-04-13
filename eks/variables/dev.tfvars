region              = "us-east-1"
cluster_name        = "dev-eks-cluster"
cluster_version     = "1.32"
authentication_mode = "API_AND_CONFIG_MAP"
node_pools          = ["system", "general-purpose"]

eks_managed_node_groups = {
  default = {
    name           = "default"
    instance_types = ["c6g.large"]
    min_size       = 1
    max_size       = 3
    desired_size   = 2
    ami_type       = "AL2_ARM_64"
    # iam_role_arn    = "arn:aws:iam::123456789012:role/eks-node-role" # Replace with your actual IAM role ARN
    create_iam_role = false
  }
}

tags = {
  Environment                             = "dev"
  Project                                 = "open-tofu-iac"
  "kubernetes.io/cluster/dev-eks-cluster" = "owned"
}