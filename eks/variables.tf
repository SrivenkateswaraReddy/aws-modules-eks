variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "eks_module_version" {
  description = "The version of the EKS module to use"
  type        = string
  default     = "20.35.0"
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "cluster_endpoint_public_access" {
  description = "Whether to enable public access to the cluster endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Whether to enable private access to the cluster endpoint"
  type        = bool
  default     = true
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

variable "cluster_ip_family" {
  description = "The IP family to use for the cluster"
  type        = string
  default     = "ipv4"
}

variable "cluster_compute_config_enabled" {
  description = "Whether to enable compute configuration for the cluster"
  type        = bool
  default     = true
}

variable "cluster_node_pools" {
  description = "List of node pools for the cluster"
  type        = list(string)
  default     = ["general-purpose"]
}

variable "node_group_desired_size" {
  description = "The desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "The maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "The minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_group_instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_capacity_type" {
  description = "The capacity type for the node group"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_ami_type" {
  description = "The AMI type for the node group"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_group_disk_size" {
  description = "The disk size in GB for the node group"
  type        = number
  default     = 20
}

variable "node_group_labels" {
  description = "Labels to add to the node group"
  type        = map(string)
  default = {
    role = "general"
  }
}

variable "node_group_taints" {
  description = "Taints to apply to the node group"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = [{
    key    = "dedicated"
    value  = "general"
    effect = "NO_SCHEDULE"
  }]
}
