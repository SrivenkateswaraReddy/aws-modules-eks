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

data "aws_subnet" "private_subnets" {
  for_each = toset(data.terraform_remote_state.vpc.outputs.private_subnet_ids)
  id       = each.value
}

locals {
  eks_cluster_role_arn = data.terraform_remote_state.iam.outputs.eks_cluster_role_arn
  eks_node_role_arn    = data.terraform_remote_state.iam.outputs.eks_node_role_arn
}
