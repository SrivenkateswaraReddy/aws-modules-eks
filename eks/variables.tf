variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "authentication_mode" {
  description = "The authentication mode for the cluster. Valid values are API, CONFIG_MAP, or both."
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  type        = string
}
variable "node_pools" {
  description = "List of built-in EKS Auto Mode node pools to enable"
  type        = list(string)
}

# variable "eks_managed_node_groups" {
#   description = "Map of EKS managed node group definitions to create"
#   type = map(object({
#     name           = string
#     instance_types = list(string)
#     min_size       = number
#     max_size       = number
#     desired_size   = number
#     ami_type       = string
#     # iam_role_arn    = string
#     create_iam_role = bool
#   }))
# }
