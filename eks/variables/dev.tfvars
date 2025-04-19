# dev.tfvars
eks_cluster_name    = "dev-eks-cluster"
eks_cluster_version = "1.32"

addons = [
  { name = "vpc-cni", version = "v1.19.2-eksbuild.5" },
  { name = "kube-proxy", version = "v1.30.0-eksbuild.1" },
  { name = "coredns", version = "v1.11.1-eksbuild.2" },
  { name = "aws-ebs-csi-driver", version = "v1.30.1-eksbuild.1" },
  { name = "aws-efs-csi-driver", version = "v1.7.1-eksbuild.1" },
  { name = "adot", version = "v1.0.0-eksbuild.1" },
  { name = "aws-network-flow-monitoring-agent", version = "v1.2.0-eksbuild.1" },
  { name = "eks-node-monitoring-agent", version = "v1.1.0-eksbuild.1" }
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
