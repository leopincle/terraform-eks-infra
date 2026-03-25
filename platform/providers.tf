terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host = data.terraform_remote_state.infra.outputs.cluster_endpoint

  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.infra.outputs.cluster_ca_certificate_authority_data
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

provider "helm" {
  kubernetes {
    host = data.terraform_remote_state.infra.outputs.cluster_endpoint

    cluster_ca_certificate = base64decode(
      data.terraform_remote_state.infra.outputs.cluster_ca_certificate_authority_data
    )

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--region", var.region,
        "--cluster-name",
        data.terraform_remote_state.infra.outputs.cluster_name
      ]
    }
  }
}