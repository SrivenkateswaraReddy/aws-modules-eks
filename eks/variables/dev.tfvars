# terraform.tfvars - Example configuration for t3.medium with high pod density

# Basic EKS Configuration
eks_cluster_name    = "dev-eks-cluster"
eks_cluster_version = "1.33"

# Enable high pod density with prefix delegation
enable_prefix_delegation = true
vpc_cni_version         = "v1.15.4-eksbuild.1"

# Network Configuration
enable_public_access = true
public_access_cidrs  = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"] # Restrict to private networks

# Security Configuration
enable_ssh_access = false  # Disable SSH for security
ssh_allowed_cidrs = []     # Empty since SSH is disabled

# Node Group Configuration (t3.medium optimized)
node_capacity_type             = "ON_DEMAND"
node_desired_size             = 2
node_max_size                 = 6
node_min_size                 = 1
node_max_unavailable_percentage = 25

# Storage Configuration
node_disk_size       = 80    # Increased for high pod density
node_volume_type     = "gp3"
node_volume_iops     = 4000  # Higher IOPS for better performance
node_volume_throughput = 200 # Higher throughput

# Spot Instances Configuration
enable_spot_instances = true
spot_desired_size     = 1
spot_max_size         = 3
spot_min_size         = 0

# Kubelet Configuration
max_pods_per_node = 110
kubelet_extra_args = "--kube-reserved=cpu=100m,memory=256Mi --system-reserved=cpu=100m,memory=256Mi"

# Logging Configuration
log_retention_days = 30

# Add-ons Configuration (excluding VPC CNI which is configured separately)
additional_addons = [
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
    version = "v1.25.0-eksbuild.1"
  },
  {
    name    = "aws-efs-csi-driver"
    version = "v1.7.0-eksbuild.1"
  }
]

# Encryption (Optional - replace with your KMS key ARN)
# kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/12345678-1234-1234-1234-123456789012"

# Tags
tags = {
  Environment   = "development"
  Project       = "high-density-eks"
  Owner         = "platform-team"
  CostCenter    = "engineering"
  Application   = "kubernetes"
  PodDensity    = "high"
  InstanceType  = "t3-medium"
}

tags_all = {
  Environment   = "development"
  Project       = "high-density-eks"
  Owner         = "platform-team"
  CostCenter    = "engineering"
  Application   = "kubernetes"
  PodDensity    = "high"
  InstanceType  = "t3-medium"
  ManagedBy     = "terraform"
}