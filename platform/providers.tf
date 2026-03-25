provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host = data.terraform_remote_state.infra.outputs.cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.infra.outputs.cluster_ca_certificate
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = [
      "eks",
      "get-token",
      "--cluster-name",
      data.terraform_remote_state.infra.outputs.cluster_name
    ]
  }
}

provider "helm" {}