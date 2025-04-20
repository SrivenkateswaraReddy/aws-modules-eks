resource "aws_eks_cluster" "dev-eks-cluster" {
  name = var.eks_cluster_name

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true

  }

  role_arn = data.terraform_remote_state.iam.outputs.eks_cluster_role_arn
  version  = var.eks_cluster_version

  vpc_config {
    subnet_ids              = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_node_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  compute_config {
    enabled = false
    # node_pools = ["general-purpose"]
    # node_role_arn = data.terraform_remote_state.iam.outputs.eks_node_role_arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = false
    }
  }

  storage_config {
    block_storage {
      enabled = false
    }
  }
  bootstrap_self_managed_addons = true

  tags     = var.tags
  tags_all = var.tags_all
  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
}


resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.dev-eks-cluster.name
  node_group_name = "graviton"
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

  #   instance_types = ["t3.medium"]
  #   ami_type       = "AL2_x86_64"
  #   disk_size      = 20

  #   instance_types = ["t3.small"]
  #   ami_type       = "AL2_x86_64"
  #   disk_size      = 20


  instance_types = [var.graviton_instance_type]
  ami_type       = var.ami_type_graviton
  disk_size      = var.node_disk_size

  tags = var.tags_all
}

resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS nodes"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = var.tags
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

resource "aws_eks_addon" "addons" {
  for_each      = { for addon in var.addons : addon.name => addon }
  cluster_name  = aws_eks_cluster.dev-eks-cluster.id
  addon_name    = each.value.name
  addon_version = each.value.version
}


######## Helm Resources ##########

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "prometheus"
  create_namespace = true

  values = [
    file("variables/values.yaml") // Customize your Helm values here
  ]
}

resource "helm_release" "otel_collector" {
  name             = "otel-collector"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-collector"
  namespace        = "observability"
  create_namespace = true

  values = [
    file("variables/otel-values.yaml") // Customize your Helm values here
  ]
}
