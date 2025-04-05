variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}


variable "cluster_name" {
  type    = string
  default = "demo-eks-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.32"
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "eks_cluster_role_arn" {
  type = string
}

variable "eks_node_role_arn" {
  type = string
}

variable "node_group_name" {
  type    = string
  default = "demo-node-group"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 2
}

variable "node_desired_size" {
  type    = number
  default = 1
}

variable "s3_bucket_details" {}
