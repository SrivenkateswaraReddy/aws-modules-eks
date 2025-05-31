# variables.tf

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_cluster_version" {
  description = "Kubernetes version to use for EKS cluster"
  type        = string
  default     = "1.33"
}

variable "enable_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# variable "kms_key_arn" {
#   description = "ARN of KMS key for encryption"
#   type        = string
#   default     = null
# }

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

# Prefix Delegation Configuration
variable "enable_prefix_delegation" {
  description = "Enable prefix delegation mode for VPC CNI to increase pod density"
  type        = bool
  default     = true
}

variable "vpc_cni_version" {
  description = "Version of the VPC CNI add-on"
  type        = string
  default     = "v1.15.4-eksbuild.1"
}

variable "vpc_cni_irsa_role_arn" {
  description = "IAM role ARN for VPC CNI service account (for IRSA)"
  type        = string
  default     = null
}
variable "node_capacity_type" {
  description = "Type of capacity associated with the EKS Node Group. Valid values: ON_DEMAND, SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_instance_types" {
  description = "List of instance types for the EKS Node Group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of nodes in the EKS Node Group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes in the EKS Node Group"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of nodes in the EKS Node Group"
  type        = number
  default     = 1
}

variable "node_max_unavailable_percentage" {
  description = "Maximum percentage of nodes unavailable during update"
  type        = number
  default     = 25
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50
}

variable "node_volume_type" {
  description = "EBS volume type for worker nodes"
  type        = string
  default     = "gp3"
}

variable "node_volume_iops" {
  description = "IOPS for gp3 volumes"
  type        = number
  default     = 3000
}

variable "node_volume_throughput" {
  description = "Throughput for gp3 volumes"
  type        = number
  default     = 125
}

variable "max_pods_per_node" {
  description = "Maximum number of pods per node"
  type        = number
  default     = 110
}

variable "kubelet_extra_args" {
  description = "Additional arguments to pass to kubelet"
  type        = string
  default     = ""
}

# Spot Instance Variables (t3.medium family)
variable "enable_spot_instances" {
  description = "Enable spot instance node group"
  type        = bool
  default     = false
}

# Removed spot_instance_types as we're using t3.medium family

variable "spot_desired_size" {
  description = "Desired number of spot instances"
  type        = number
  default     = 1
}

variable "spot_max_size" {
  description = "Maximum number of spot instances"
  type        = number
  default     = 3
}

variable "spot_min_size" {
  description = "Minimum number of spot instances"
  type        = number
  default     = 0
}

# Security Variables
variable "enable_ssh_access" {
  description = "Enable SSH access to worker nodes"
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "List of CIDR blocks allowed to SSH to nodes"
  type        = list(string)
  default     = []
}

# Add-ons (separated VPC CNI from other add-ons)
variable "additional_addons" {
  description = "List of additional EKS add-ons to install (excluding VPC CNI)"
  type = list(object({
    name    = string
    version = string
  }))
  default = [
    {
      name    = "coredns"
      version = "v1.10.1-eksbuild.4"
    },
    {
      name    = "kube-proxy"
      version = "v1.28.2-eksbuild.2"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.24.0-eksbuild.1"
    }
  ]
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "tags_all" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}