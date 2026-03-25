data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "devops-leo-terraform-state"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

########################################
# ArgoCD
########################################
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"

  set {
      name = "crds.install"
      value = "true"
    }
  

  create_namespace = true

  values = [
    <<EOF
server:
  service:
    type: LoadBalancer
EOF
  ]
}

########################################
# Prometheus
########################################
resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  create_namespace = true

  values = [
    <<EOF
grafana:
  service:
    type: LoadBalancer
EOF
  ]
}

