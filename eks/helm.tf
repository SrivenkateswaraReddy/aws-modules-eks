

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "grafana"
  namespace        = "grafana"
  version          = "8.12.1" # Replace with the desired chart version
  create_namespace = true
  values           = [file("${path.module}/variables/grafana-values.yaml")]
}


resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus"
  namespace        = "prometheus"
  version          = "27.11.0" # Replace with the desired chart version
  create_namespace = true

  values = [file("${path.module}/variables/prometheus-values.yaml")]
}
