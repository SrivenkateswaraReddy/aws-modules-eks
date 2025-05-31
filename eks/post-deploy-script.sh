#!/bin/bash
# post-deployment-setup.sh
# Script to verify and optimize EKS cluster for high pod density

set -e

CLUSTER_NAME="${1:dev-eks-cluster}"
AWS_REGION="${2:us-east-1}"

echo "=== EKS High Pod Density Setup and Verification ==="
echo "Cluster: $CLUSTER_NAME"
echo "Region: $AWS_REGION"
echo "=================================================="

# Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

# Verify cluster connectivity
echo "Verifying cluster connectivity..."
kubectl get nodes

# Check VPC CNI configuration
echo "Checking VPC CNI configuration..."
kubectl describe daemonset aws-node -n kube-system | grep -A 10 -B 5 "ENABLE_PREFIX_DELEGATION\|WARM_PREFIX_TARGET"

# Verify prefix delegation is enabled
echo "Current VPC CNI environment variables:"
kubectl get daemonset aws-node -n kube-system -o jsonpath='{.spec.template.spec.containers[0].env[*]}' | jq -r '.[] | select(.name | test("PREFIX|WARM|IP_TARGET")) | "\(.name)=\(.value)"'

# If prefix delegation is not enabled, enable it
echo "Enabling prefix delegation (if not already enabled)..."
kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
kubectl set env daemonset aws-node -n kube-system WARM_PREFIX_TARGET=1
kubectl set env daemonset aws-node -n kube-system WARM_IP_TARGET=5
kubectl set env daemonset aws-node -n kube-system MINIMUM_IP_TARGET=3

# Wait for aws-node daemonset to restart
echo "Waiting for aws-node daemonset to restart..."
kubectl rollout status daemonset/aws-node -n kube-system --timeout=300s

# Restart existing nodes to pick up new settings (optional but recommended)
echo "Note: You may want to restart existing nodes to pick up new VPC CNI settings"
echo "This can be done by term