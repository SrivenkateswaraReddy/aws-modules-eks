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

 provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

 provider "kubectl" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}