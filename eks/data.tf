data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = "my-aws-terraform-s3-backend-vicky"
    key    = "modules/iam/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "my-aws-terraform-s3-backend-vicky"
    key    = "modules/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks_cluster.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = <<YAML
#     - rolearn: ${data.terraform_remote_state.iam.outputs.eks_node_role_arn}  # Verify output name
#       username: system:node:{{EC2PrivateDNSName}}
#       groups:
#         - system:bootstrappers
#         - system:nodes
#     YAML
#   }

#   depends_on = [
#     aws_eks_cluster.eks_cluster,
#     data.terraform_remote_state.iam # Ensure IAM state is available
#   ]
# }
