#!/bin/bash
# userdata.sh - EKS Node Bootstrap with High Pod Density Support

# Exit on any error
set -e

# Configure logging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting EKS node bootstrap process for t3.medium with high pod density..."

# Update system packages
yum update -y

# Install CloudWatch agent (optional)
yum install -y amazon-cloudwatch-agent

# Install additional packages for troubleshooting
yum install -y htop iotop

# Configure kubelet arguments for t3.medium with high pod density
KUBELET_ARGS="--max-pods=${max_pods}"

# Add additional kubelet arguments if provided
if [ -n "${additional_args}" ]; then
    KUBELET_ARGS="$KUBELET_ARGS ${additional_args}"
fi

echo "Configuring kubelet with args: $KUBELET_ARGS"

# If prefix delegation is enabled, add CNI-specific arguments
%{ if prefix_delegation }
echo "Prefix delegation enabled - optimizing for high pod density"

# Set additional system parameters for high pod density
echo 'net.core.rmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_default = 262144' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 65536 16777216' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 16777216' >> /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 5000' >> /etc/sysctl.conf
echo 'fs.file-max = 1000000' >> /etc/sysctl.conf

# Apply sysctl changes
sysctl -p

# Increase system limits for high pod density
echo '* soft nofile 1000000' >> /etc/security/limits.conf
echo '* hard nofile 1000000' >> /etc/security/limits.conf
echo '* soft nproc 1000000' >> /etc/security/limits.conf
echo '* hard nproc 1000000' >> /etc/security/limits.conf

%{ endif }

# Bootstrap the node
echo "Bootstrapping node with EKS cluster: ${cluster_name}"
/etc/eks/bootstrap.sh ${cluster_name} \
    --kubelet-extra-args "$KUBELET_ARGS" \
    --container-runtime containerd \
    --b64-cluster-ca ${cluster_ca} \
    --apiserver-endpoint ${cluster_endpoint}

# Verify bootstrap success
echo "Checking kubelet service status..."
systemctl status kubelet --no-pager

# Log current max pods configuration
echo "Current max pods configuration:"
cat /etc/kubernetes/kubelet/kubelet-config.json | grep -A 5 -B 5 maxPods || echo "maxPods not found in config"

# Optional: Configure additional monitoring or logging
# systemctl enable amazon-cloudwatch-agent
# systemctl start amazon-cloudwatch-agent

echo "EKS node bootstrap completed successfully"
echo "Node is configured for high pod density with max pods: ${max_pods}"

# Final verification
echo "=== Node Configuration Summary ==="
echo "Instance Type: t3.medium"
echo "Max Pods: ${max_pods}"
echo "Prefix Delegation: ${prefix_delegation}"
echo "================================="