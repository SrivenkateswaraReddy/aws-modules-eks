# EKS Cluster
resource "aws_eks_cluster" "dev_eks_cluster" {
  name     = var.eks_cluster_name
  version  = var.eks_cluster_version
  role_arn = data.terraform_remote_state.iam.outputs.eks_cluster_role_arn

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = var.enable_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  # Enable logging for better observability
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  # Encryption at rest
  # encryption_config {
  #   provider {
  #     key_arn = var.kms_key_arn
  #   }
  #   resources = ["secrets"]
  # }

  bootstrap_self_managed_addons = true

  tags = merge(var.tags, {
    Name = var.eks_cluster_name
  })

  depends_on = [
    aws_cloudwatch_log_group.eks_cluster_logs
  ]
}

# CloudWatch Log Group for EKS cluster logs
resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = var.log_retention_days
  # kms_key_id        = var.kms_key_arn

  tags = var.tags
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "${var.eks_cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(var.tags, {
    Name = "${var.eks_cluster_name}-cluster-sg"
  })
}

# EKS Node Group Security Group
resource "aws_security_group" "eks_node_sg" {
  name_prefix = "${var.eks_cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  tags = merge(var.tags, {
    Name = "${var.eks_cluster_name}-node-sg"
  })
}

# Security Group Rules for Cluster
resource "aws_security_group_rule" "cluster_ingress_node_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_node_sg.id
  security_group_id        = aws_security_group.eks_cluster_sg.id
  description              = "Allow nodes to communicate with cluster API"
}

# Security Group Rules for Nodes
resource "aws_security_group_rule" "node_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.eks_node_sg.id
  description       = "Allow nodes to communicate with each other"
}

resource "aws_security_group_rule" "node_ingress_cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster_sg.id
  security_group_id        = aws_security_group.eks_node_sg.id
  description              = "Allow cluster control plane to communicate with nodes"
}

# Conditional SSH access (only if enabled)
resource "aws_security_group_rule" "node_ingress_ssh" {
  count             = var.enable_ssh_access ? 1 : 0
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_allowed_cidrs
  security_group_id = aws_security_group.eks_node_sg.id
  description       = "SSH access to nodes"
}

resource "aws_security_group_rule" "node_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_node_sg.id
  description       = "Allow all outbound traffic"
}

# Launch Template for t3.medium instances with max pod support
resource "aws_launch_template" "eks_nodes" {
  name_prefix            = "${var.eks_cluster_name}-t3-medium-template"
  description            = "Launch template for EKS t3.medium worker nodes with high pod density"
  update_default_version = true

  instance_type = "t3.medium"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.node_disk_size
      volume_type = var.node_volume_type
      iops        = var.node_volume_type == "gp3" ? var.node_volume_iops : null
      throughput  = var.node_volume_type == "gp3" ? var.node_volume_throughput : null
      encrypted   = true
      # kms_key_id            = var.kms_key_arn
      delete_on_termination = true
    }
  }

  vpc_security_group_ids = [aws_security_group.eks_node_sg.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    cluster_name      = aws_eks_cluster.dev_eks_cluster.name
    cluster_endpoint  = aws_eks_cluster.dev_eks_cluster.endpoint
    cluster_ca        = aws_eks_cluster.dev_eks_cluster.certificate_authority[0].data
    max_pods          = 110 # Maximum pods for t3.medium with prefix delegation
    additional_args   = var.kubelet_extra_args
    prefix_delegation = var.enable_prefix_delegation
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.eks_cluster_name}-t3-medium-node"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.eks_cluster_name}-t3-medium-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

# # Managed Node Groups - t3.medium optimized
# resource "aws_eks_node_group" "general" {
#   cluster_name    = aws_eks_cluster.dev_eks_cluster.name
#   node_group_name = "t3-medium-general"
#   node_role_arn   = data.terraform_remote_state.iam.outputs.eks_node_role_arn
#   subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnet_ids

#   capacity_type = var.node_capacity_type
#   # instance_types = ["t3.medium"] # Fixed to t3.medium for consistent performance

#   scaling_config {
#     desired_size = var.node_desired_size
#     max_size     = var.node_max_size
#     min_size     = var.node_min_size
#   }

#   update_config {
#     max_unavailable_percentage = var.node_max_unavailable_percentage
#   }

#   launch_template {
#     id      = aws_launch_template.eks_nodes.id
#     version = aws_launch_template.eks_nodes.latest_version
#   }

#   # Ensure proper ordering of resource creation and destruction
#   depends_on = [
#     aws_eks_cluster.dev_eks_cluster,
#     aws_eks_addon.vpc_cni, # Ensure VPC CNI is configured before nodes
#   ]

#   lifecycle {
#     ignore_changes = [scaling_config[0].desired_size]
#   }

#   tags = merge(var.tags, {
#     Name                                                = "${var.eks_cluster_name}-t3-medium-nodes"
#     "k8s.io/cluster-autoscaler/enabled"                 = "true"
#     "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
#   })
# }

# Optional: Spot instance node group for t3.medium
resource "aws_eks_node_group" "spot" {
  count = var.enable_spot_instances ? 1 : 0

  cluster_name    = aws_eks_cluster.dev_eks_cluster.name
  node_group_name = "t3-medium-spot"
  node_role_arn   = data.terraform_remote_state.iam.outputs.eks_node_role_arn
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  capacity_type = "SPOT"
  # instance_types = ["t3.medium", "t3a.medium"] # Similar performance instances

  scaling_config {
    desired_size = var.spot_desired_size
    max_size     = var.spot_max_size
    min_size     = var.spot_min_size
  }

  update_config {
    max_unavailable_percentage = var.node_max_unavailable_percentage
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  # Taints for spot instances
  taint {
    key    = "node.kubernetes.io/instance-type"
    value  = "spot"
    effect = "NO_SCHEDULE"
  }

  depends_on = [
    aws_eks_cluster.dev_eks_cluster,
    aws_eks_addon.vpc_cni,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = merge(var.tags, {
    Name                                                = "${var.eks_cluster_name}-t3-medium-spot-nodes"
    "k8s.io/cluster-autoscaler/enabled"                 = "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
  })
}

# EKS Add-ons with VPC CNI configured for prefix delegation
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.dev_eks_cluster.id
  addon_name                  = "vpc-cni"
  addon_version               = var.vpc_cni_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = var.vpc_cni_irsa_role_arn

  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = var.enable_prefix_delegation ? "true" : "false"
      WARM_PREFIX_TARGET       = var.enable_prefix_delegation ? "1" : "0"
      WARM_IP_TARGET           = var.enable_prefix_delegation ? "5" : "1"
      MINIMUM_IP_TARGET        = var.enable_prefix_delegation ? "3" : "1"
    }
  })

  tags = merge(var.tags, {
    Name = "${var.eks_cluster_name}-vpc-cni"
  })
}

resource "aws_eks_addon" "addons" {
  for_each                    = { for addon in var.additional_addons : addon.name => addon }
  cluster_name                = aws_eks_cluster.dev_eks_cluster.id
  addon_name                  = each.value.name
  addon_version               = each.value.version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.spot,
    aws_eks_addon.vpc_cni,
  ]

  tags = var.tags
}

# OIDC Identity Provider
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.dev_eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.dev_eks_cluster.identity[0].oidc[0].issuer

  tags = var.tags
}

