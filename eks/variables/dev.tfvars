# dev.tfvars
eks_cluster_name    = "dev-eks-cluster"
eks_cluster_version = "1.32"

addons = [
  { name = "vpc-cni",     version = "v1.15.4-eksbuild.1" },
  { name = "kube-proxy",  version = "v1.29.0-eksbuild.1" },
  { name = "coredns",     version = "v1.11.1-eksbuild.1" }
]

ssh_access_cidr   = ["0.0.0.0/0"]
https_access_cidr = ["0.0.0.0/0"]

graviton_instance_type = "t4g.medium"

graviton_node_scaling = {
  desired_size = 1
  max_size     = 2
  min_size     = 1
}

node_disk_size = 20

ami_type_graviton = "AL2_ARM_64"

project_name = "open-tofu-iac"
environment  = "dev"

additional_tags = {
  Owner      = "devops-team"
  CostCenter = "12345"
}
