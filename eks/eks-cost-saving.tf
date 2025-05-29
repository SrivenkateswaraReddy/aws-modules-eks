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
}

resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS nodes"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  tags        = var.tags
}

resource "aws_security_group_rule" "eks_node_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.eks_node_sg.id
}

resource "aws_security_group_rule" "eks_node_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
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

resource "aws_launch_template" "t3_small_custom" {
  name_prefix   = "eks-custom-t3small-"
  instance_type = "t3.small"

  user_data = base64encode(<<-EOF
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="==BOUNDARY=="

    --==BOUNDARY==
    Content-Type: text/x-shellscript; charset="us-ascii"

    #!/bin/bash
    /etc/eks/bootstrap.sh ${aws_eks_cluster.dev-eks-cluster.name} \
      --kubelet-extra-args '--max-pods=80'

    --==BOUNDARY==--
  EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags_all
  }
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.dev-eks-cluster.name
  node_group_name = "general"
  node_role_arn   = data.terraform_remote_state.iam.outputs.eks_node_role_arn
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  scaling_config {
    desired_size = 0
    max_size     = 2
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.t3_small_custom.id
    version = "$Latest"
  }

  capacity_type = "SPOT"
  tags          = var.tags_all
}

resource "aws_eks_addon" "essential_addons" {
  for_each = toset(["vpc-cni", "kube-proxy"])

  cluster_name = aws_eks_cluster.dev-eks-cluster.name
  addon_name   = each.key

  # Let AWS pick the latest compatible version
  resolve_conflicts = "OVERWRITE"
}

# Optional: Auto shutdown Lambda
resource "aws_lambda_function" "eks_auto_shutdown" {
  count         = var.enable_auto_shutdown ? 1 : 0
  filename      = "eks_shutdown.zip"
  function_name = "eks-auto-shutdown"
  role          = aws_iam_role.lambda_role[0].arn
  handler       = "index.handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256
  tags             = var.tags
}

data "archive_file" "lambda_zip" {
  count       = var.enable_auto_shutdown ? 1 : 0
  type        = "zip"
  output_path = "eks_shutdown.zip"
  source {
    content  = <<EOF
import boto3
import json

def handler(event, context):
    eks = boto3.client('eks')
    eks.update_nodegroup_config(
        clusterName='${var.eks_cluster_name}',
        nodegroupName='general',
        scalingConfig={
            'minSize': 0,
            'maxSize': 2,
            'desiredSize': 0
        }
    )
    return {
        'statusCode': 200,
        'body': json.dumps('EKS nodes scaled down')
    }
EOF
    filename = "index.py"
  }
}

resource "aws_iam_role" "lambda_role" {
  count = var.enable_auto_shutdown ? 1 : 0
  name  = "eks-lambda-shutdown-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "eks_shutdown_schedule" {
  count               = var.enable_auto_shutdown ? 1 : 0
  name                = "eks-shutdown-schedule"
  description         = "Trigger EKS shutdown at 10 PM"
  schedule_expression = "cron(0 22 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count     = var.enable_auto_shutdown ? 1 : 0
  rule      = aws_cloudwatch_event_rule.eks_shutdown_schedule[0].name
  target_id = "EKSShutdownTarget"
  arn       = aws_lambda_function.eks_auto_shutdown[0].arn
}

variable "enable_auto_shutdown" {
  description = "Enable automatic shutdown of EKS nodes"
  type        = bool
  default     = false
}
