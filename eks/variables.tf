variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}
variable "addons" {
  description = "List of EKS add-ons to install"
  type = list(object({
    name    = string
    version = string
  }))
}

variable "eks_cluster_name" {
  description = "Name of the eks cluster"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.32"
}

variable "ssh_access_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_access_cidr" {
  description = "CIDR blocks allowed for HTTPS access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "graviton_instance_type" {
  description = "Instance type for Graviton node group"
  type        = string
  default     = "t4g.medium"
}


variable "graviton_node_scaling" {
  description = "Scaling configuration for Graviton node group"
  type = object({
    desired_size = number
    max_size     = number
    min_size     = number
  })
  default = {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
}

variable "node_disk_size" {
  description = "Disk size for worker nodes in GB"
  type        = number
  default     = 20
}

variable "ami_type_graviton" {
  description = "AMI type for Graviton nodes"
  type        = string
  default     = "AL2_ARM_64"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "open-tofu-iac"
}



variable "additional_tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "tags_all" {
  description = "A map of all tags to assign to resources"
  type        = map(string)
  default     = {}
}
