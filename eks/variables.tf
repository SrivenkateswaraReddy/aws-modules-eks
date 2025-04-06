variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

# variable "s3_bucket_details" {}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

# variable "vpc_id" {
#   type = string
# }

# variable "subnet_ids" {
#   type = list(string)
# }

# variable "eks_cluster_role_arn" {
#   type = string
# }

# variable "eks_node_role_arn" {
#   type = string
# }

variable "node_group_name" {
  type = string
}

variable "node_instance_type" {
  type = string
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "node_desired_size" {
  type = number
}
