data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = var.s3_bucket_details
    key    = "modules/iam/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.s3_bucket_details
    key    = "modules/vpc/terraform.tfstate"
    region = "us-east-1"
  }
}
