resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "36.6.2" # Specify the desired chart version
  create_namespace = true

  values = [
    file("${path.module}/variables/prometheus-values.yaml")
  ]
}

resource "kubernetes_namespace" "otel_collector" {
  metadata {
    name = "otel-collector"
    labels = {
      provisioned_by = "terraform"
    }
  }
}

resource "helm_release" "otel_collector" {
  name             = "otel-collector"
  repository       = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart            = "opentelemetry-collector"
  namespace        = kubernetes_namespace.otel_collector.metadata[0].name
  create_namespace = false
  version          = "0.41.0" # Specify the desired chart version

  values = [
    file("${path.module}/variables/otel-values.yaml")
  ]
}
