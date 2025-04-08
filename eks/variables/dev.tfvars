eks_module_version = "20.35.0"
cluster_name = "your-cluster-name"
cluster_version = "1.32"
cluster_endpoint_public_access = true
cluster_endpoint_private_access = true
enable_irsa = true
cluster_ip_family = "ipv4"
cluster_compute_config_enabled = true
cluster_node_pools = ["general-purpose"]
node_group_desired_size = 2
node_group_max_size = 3
node_group_min_size = 1
node_group_instance_types = ["t3.medium"]
node_group_capacity_type = "ON_DEMAND"
node_group_ami_type = "AL2_x86_64"
node_group_disk_size = 20
node_group_labels = {
  role = "general"
}
node_group_taints = [
  {
    key    = "dedicated"
    value  = "general"
    effect = "NO_SCHEDULE"
  }
]
