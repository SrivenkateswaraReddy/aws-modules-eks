resource "aws_eks_cluster" "dev-eks-cluster" {
  name = "dev-eks-cluster"

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true

  }

  role_arn = data.terraform_remote_state.iam.outputs.eks_cluster_role_arn
  version  = "1.32"

  vpc_config {
    subnet_ids              = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_node_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose", "system"]
    node_role_arn = data.terraform_remote_state.iam.outputs.eks_node_role_arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }
  bootstrap_self_managed_addons = false

  tags = {
    Project     = "open-tofu-iac"
    Environment = "dev"
    Name        = "tfe_vpc"
  }
  tags_all = {
    "Environment"                           = "dev"
    "Name"                                  = "tfe_vpc"
    "Project"                               = "open-tofu-iac"
    "kubernetes.io/cluster/dev-eks-cluster" = "owned"
  }
  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
}

resource "aws_eks_node_group" "general-purpose" {
  cluster_name    = aws_eks_cluster.dev-eks-cluster.name
  node_group_name = "general-purpose"
  node_role_arn   = data.terraform_remote_state.iam.outputs.eks_node_role_arn

  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  ami_type       = "AL2_x86_64"
  disk_size      = 20

  tags = {
    Environment                             = "dev"
    Project                                 = "open-tofu-iac"
    Name                                    = "general-purpose"
    "kubernetes.io/cluster/dev-eks-cluster" = "owned"
  }
}

resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.dev-eks-cluster.name
  node_group_name = "system"
  node_role_arn   = data.terraform_remote_state.iam.outputs.eks_node_role_arn

  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }

  instance_types = ["t3.small"]
  ami_type       = "AL2_x86_64"
  disk_size      = 20

  tags = {
    Environment                             = "dev"
    Project                                 = "open-tofu-iac"
    Name                                    = "system"
    "kubernetes.io/cluster/dev-eks-cluster" = "owned"
  }
}

resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS nodes"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = {
    Name        = "eks-node-sg"
    Environment = "dev"
    Project     = "open-tofu-iac"
  }
}

resource "aws_security_group_rule" "eks_node_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_node_sg.id
}

resource "aws_security_group_rule" "eks_node_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_node_sg.id
}


resource "aws_security_group_rule" "eks_node_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_node_sg.id
}

resource "aws_eks_addon" "example" {
  cluster_name = aws_eks_cluster.dev-eks-cluster.name
  addon_name   = "vpc-cni"
}
