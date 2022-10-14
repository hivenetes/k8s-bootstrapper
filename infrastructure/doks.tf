
 terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
  # Enable the "cloud" block if you are using Terraform cloud 
  # Swap workspaces between "staging" and "dev"
    # cloud {
    #   organization = "diabhey"
    #   workspaces {
    #     name = "staging"
    #   }
    # }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name         = var.name
  region       = var.region
  version      = var.k8s_version
  vpc_uuid     = var.vpc_uuid
  auto_upgrade = var.auto_upgrade
  surge_upgrade = var.surge_upgrade
  ha           = var.ha

  node_pool {
    name = var.node_pool.name
    size = var.node_pool.size
    node_count = var.node_pool.node_count
    auto_scale = var.node_pool.auto_scale
    min_nodes = var.node_pool.min_nodes
    max_nodes = var.node_pool.max_nodes
  }

}

# Create a new container registry
resource "digitalocean_container_registry" "registry" {
  name                   = var.container_registry
  subscription_tier_slug = "basic"
}
