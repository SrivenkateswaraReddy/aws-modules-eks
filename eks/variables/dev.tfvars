# dev.tfvars
eks_cluster_name    = "dev-eks-cluster"
eks_cluster_version = "1.32"

addons = [
  { name = "vpc-cni", version = "v1.19.2-eksbuild.5" },
  { name = "kube-proxy", version = "v1.32.0-eksbuild.2" },
  # { name = "coredns", version = "v1.11.1-eksbuild.2" },
  { name = "aws-ebs-csi-driver", version = "v1.29.1-eksbuild.1" }, # Replace with CLI output
  # { name = "adot", version = "vX.Y.Z-eksbuild.N" }, # Not supported for 1.32 yet
  # { name = "aws-network-flow-monitoring-agent", version = "..." }, # Check with CLI
  # { name = "eks-node-monitoring-agent", version = "..." } # Check with CLI
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

tags = {
  Project     = "open-tofu-iac"
  Environment = "dev"
  Name        = "tfe_vpc"
}

tags_all = {
  Environment                             = "dev"
  Name                                    = "tfe_vpc"
  Project                                 = "open-tofu-iac"
  "kubernetes.io/cluster/dev-eks-cluster" = "owned"
}
