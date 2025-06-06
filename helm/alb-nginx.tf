# ALB IAM Policy for AWS Load Balancer Controller
resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${data.terraform_remote_state.eks.outputs.cluster_name}-aws-lb-controller-policy"
  description = "IAM policy for AWS Load Balancer Controller"

  policy = file("${path.module}/aws_lb_controller_policy.json")
}

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "${data.terraform_remote_state.eks.outputs.cluster_name}-aws-lb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.terraform_remote_state.eks.outputs.oidc_provider_arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.terraform_remote_state.eks.outputs.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          "${replace(data.terraform_remote_state.eks.outputs.oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Environment = var.environment
    Name        = "${data.terraform_remote_state.eks.outputs.cluster_name}-aws-lb-controller"
  }
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

# Kubernetes Service Account for LB Controller
resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller.arn
    }
  }
}

# Helm Release for AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"
  version    = "1.13.2"

  set {
    name  = "clusterName"
    value = data.terraform_remote_state.eks.outputs.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_load_balancer_controller.metadata[0].name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = data.terraform_remote_state.vpc.outputs.vpc_id
  }

  depends_on = [
    kubernetes_service_account.aws_load_balancer_controller
  ]
}

# Helm Chart for NGINX Ingress Controller
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.8.3"

  create_namespace = true

  values = [
    yamlencode({
      controller = {
        service = {
          type = "NodePort"
          nodePorts = {
            http  = 30080
            https = 30443
          }
        }
        ingressClassResource = {
          name    = "nginx"
          enabled = true
          default = true
        }
        config = {
          use-forwarded-headers      = "true"
          compute-full-forwarded-for = "true"
          use-proxy-protocol         = "false"
        }
        metrics = {
          enabled = true
        }
      }
    })
  ]

  depends_on = [helm_release.aws_load_balancer_controller]
}

# ALB Ingress for NGINX Controller
resource "kubernetes_ingress_v1" "nginx_alb" {
  metadata {
    name      = "nginx-alb-ingress"
    namespace = "ingress-nginx"
    annotations = {
      "kubernetes.io/ingress.class"                = "alb"
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "instance"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([{ HTTP = 80 }, var.certificate_arn != "" ? { HTTPS = 443 } : {}])
      "alb.ingress.kubernetes.io/certificate-arn"  = var.certificate_arn != "" ? var.certificate_arn : null
      "alb.ingress.kubernetes.io/ssl-redirect"     = var.certificate_arn != "" ? "443" : null
      "alb.ingress.kubernetes.io/healthcheck-path" = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-port" = "10254"
      "alb.ingress.kubernetes.io/subnets"          = join(",", data.terraform_remote_state.vpc.outputs.public_subnet_ids)
      "alb.ingress.kubernetes.io/tags"             = "Environment=${var.environment},ManagedBy=terraform"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "nginx-ingress-ingress-nginx-controller"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.nginx_ingress,
    helm_release.aws_load_balancer_controller
  ]
}
