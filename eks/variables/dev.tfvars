tags = {
  Environment = "dev"
  Project     = "open-tofu-iac"
}
# dev.tfvars

cluster_name    = "dev-eks-cluster"
cluster_version = "1.32"
# vpc_id              = "vpc-0abcd1234efgh5678"
# subnet_ids          = ["subnet-0abcd1234efgh5678", "subnet-1abcd1234efgh5678"]
# eks_cluster_role_arn = "arn:aws:iam::123456789012:role/EKSClusterRole"
# eks_node_role_arn    = "arn:aws:iam::123456789012:role/EKSNodeRole"
node_group_name    = "dev-node-group"
node_instance_type = "t3.medium"
node_min_size      = 1
node_max_size      = 3
node_desired_size  = 1
