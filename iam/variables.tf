variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
variable "cluster_role_name" {
  type    = string
  default = "eks-cluster-role"
}

variable "node_role_name" {
  type    = string
  default = "eks-node-role"
}
