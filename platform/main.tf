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

  wait = true
  timeout = 600

  set = {
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

resource "time_sleep" "wait_for_argocd" {
  depends_on = [helm_release.argocd]
  create_duration = "30s"
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

########################################
# ArgoCD App (GitOps)
########################################
resource "kubernetes_manifest" "argocd_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "ci-cd-app"
      namespace = "argocd"
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/leopincle/gitops-helm-argocd.git"
        targetRevision = "main"
        path           = "helm/ci-cd-app"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    time_sleep.wait_for_argocd
  ]
}