resource "helm_release" "nginx_ingress" {
  name       = "aws-load-balancer-controller"
  namespace = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name = "clusterName"
    value = "${var.cluster_name}"
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}
resource "helm_release" "prometheus_stack" {
  chart = "../helm/kube-prometheus-stack"
  name  = "prom"
  namespace = "monitoring"
}
resource "helm_release" "loki" {
  chart = "loki-stack"
  name  = "loki"
  repository = "https://grafana.github.io/helm-charts"
  namespace = "monitoring"
}