# outputs.tf
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = "Check AWS Console for ALB DNS name or run: kubectl get ingress nginx-alb-ingress -n ingress-nginx"
}

output "nginx_controller_service" {
  description = "NGINX Ingress Controller service details"
  value       = "kubectl get svc -n ingress-nginx"
}

output "load_balancer_controller_status" {
  description = "AWS Load Balancer Controller status"
  value       = "kubectl get deployment -n kube-system aws-load-balancer-controller"
}

output "demo_app_url" {
  description = "Demo application URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}/demo" : "Access via ALB DNS name + /demo"
}

output "kubectl_commands" {
  description = "Useful kubectl commands"
  value = {
    "check_alb_ingress"    = "kubectl get ingress nginx-alb-ingress -n ingress-nginx"
    "check_nginx_pods"     = "kubectl get pods -n ingress-nginx"
    "check_alb_controller" = "kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller"
    "get_alb_address"      = "kubectl get ingress nginx-alb-ingress -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
  }
}