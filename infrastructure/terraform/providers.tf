terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.25.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0"
    }
  }
  # Enable the "cloud" block if you are using Terraform cloud 
  # Swap workspaces between "staging" and "dev"
  #   cloud {
  #     organization = "diabhey"
  #     workspaces {
  #       name = "staging"
  #     }
  #   }
}

locals {
  doks_config         = digitalocean_kubernetes_cluster.bootstrapper.kube_config[0].raw_config
  doks_endpoint       = digitalocean_kubernetes_cluster.bootstrapper.endpoint
  doks_token          = digitalocean_kubernetes_cluster.bootstrapper.kube_config[0].token
  doks_ca_certificate = digitalocean_kubernetes_cluster.bootstrapper.kube_config[0].cluster_ca_certificate
}

provider "digitalocean" {
  token = var.do_token
  spaces_access_id  = var.s3_bucket_access_key_id
  spaces_secret_key = var.s3_bucket_access_key_secret
}

provider "kubernetes" {
  host  = local.doks_endpoint
  token = local.doks_token
  cluster_ca_certificate = base64decode(
    local.doks_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = local.doks_endpoint
    token = local.doks_token
    cluster_ca_certificate = base64decode(
      local.doks_ca_certificate
    )
  }
}
