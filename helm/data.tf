data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket = "my-aws-terraform-s3-backend-vicky"
    key    = "modules/eks/terraform.tfstate"
    region = "us-east-1"
  }
}

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
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_iam_openid_connect_provider" "eks" {
  url = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "/$", "")
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "main" {
  id = data.terraform_remote_state.vpc.outputs.vpc_id
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.vpc.outputs.vpc_id]
  }
  filter {
    name   = "tag:kubernetes.io/role/elb"
    values = ["1"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.vpc.outputs.vpc_id]
  }
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}
