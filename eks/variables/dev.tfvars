# dev.tfvars
eks_cluster_name    = "dev-eks-cluster"
eks_cluster_version = "1.32"

addons = [
  { name = "vpc-cni", version = "v1.19.3-eksbuild.1" },
  { name = "kube-proxy", version = "v1.32.0-eksbuild.2" },
  # { name = "coredns", version = "v1.11.1-eksbuild.2" },
  { name = "aws-ebs-csi-driver", version = "v1.41.0-eksbuild.1" }, # Replace with CLI output
  # { name = "adot", version = "vX.Y.Z-eksbuild.N" }, # Not supported for 1.32 yet
  # { name = "aws-network-flow-monitoring-agent", version = "..." }, # Check with CLI
  # { name = "eks-node-monitoring-agent", version = "..." } # Check with CLI
]

ssh_access_cidr   = ["0.0.0.0/0"]
https_access_cidr = ["0.0.0.0/0"]

graviton_instance_type = "t4g.medium"

graviton_node_scaling = {
  desired_size = 1
  max_size     = 2
  min_size     = 1
}

node_disk_size = 20

ami_type_graviton = "AL2_ARM_64"

project_name = "open-tofu-iac"
environment  = "dev"

additional_tags = {
  Owner      = "devops-team"
  CostCenter = "12345"
}

tags = {
  Project     = "open-tofu-iac"
  Environment = "dev"
  Name        = "tfe_vpc"
}

tags_all = {
  Environment                             = "dev"
  Name                                    = "tfe_vpc"
  Project                                 = "open-tofu-iac"
  "kubernetes.io/cluster/dev-eks-cluster" = "owned"
}


# kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
# KQRhSTp7shchVS83Ph0Vc9UrLjBWEZG2RXSYMNjb


# helm install prometheus prometheus-community/prometheus --namespace prometheus

# NAME: prometheus
# LAST DEPLOYED: Sun Apr 20 12:17:21 2025
# NAMESPACE: prometheus
# STATUS: deployed
# REVISION: 1
# TEST SUITE: None
# NOTES:
# The Prometheus server can be accessed via port 80 on the following DNS name from within your cluster:
# prometheus-server.prometheus.svc.cluster.local


# Get the Prometheus server URL by running these commands in the same shell:
#   export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=prometheus,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
#   kubectl --namespace prometheus port-forward $POD_NAME 9090


# The Prometheus alertmanager can be accessed via port 9093 on the following DNS name from within your cluster:
# prometheus-alertmanager.prometheus.svc.cluster.local


# Get the Alertmanager URL by running these commands in the same shell:
#   export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/name=alertmanager,app.kubernetes.io/instance=prometheus" -o jsonpath="{.items[0].metadata.name}")
#   kubectl --namespace prometheus port-forward $POD_NAME 9093
# #################################################################################
# ######   WARNING: Pod Security Policy has been disabled by default since    #####
# ######            it deprecated after k8s 1.25+. use                        #####
# ######            (index .Values "prometheus-node-exporter" "rbac"          #####
# ###### .          "pspEnabled") with (index .Values                         #####
# ######            "prometheus-node-exporter" "rbac" "pspAnnotations")       #####
# ######            in case you still need it.                                #####
# #################################################################################


# The Prometheus PushGateway can be accessed via port 9091 on the following DNS name from within your cluster:
# prometheus-prometheus-pushgateway.prometheus.svc.cluster.local


# Get the PushGateway URL by running these commands in the same shell:
#   export POD_NAME=$(kubectl get pods --namespace prometheus -l "app=prometheus-pushgateway,component=pushgateway" -o jsonpath="{.items[0].metadata.name}")
#   kubectl --namespace prometheus port-forward $POD_NAME 9091

# For more information on running Prometheus, visit:
# https://prometheus.io/