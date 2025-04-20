terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.94.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}

# provider "kubernetes" {
#   host                   = aws_eks_cluster.dev-eks-cluster.id                          # Or data source/variable
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data) # Or data source/variable
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id] # Or data source/variable
#   }
# }
