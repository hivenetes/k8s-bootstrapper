
 terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_kubernetes_cluster" "abhi-playground" {
  name   = "abhi-playground" // variable it
  # Find and change the value to an availble datacenter region close to you
  # See DO datacenter regions with the command doctl compute region list
  region = "ams3" // variable it
  auto_upgrade = true
  # Grab the latest DO Kubernetes version slug 
  # See the available versions with the command doctl kubernetes options versions
  version = "1.24.4-do.0" //variable it
  ha = true

  node_pool {
    name       = "island-pool"
    # This is a Basic AMD Droplet with 2 vCPUs and 4GB RAM
    # show droplet sizes with the command doctl compute size list
    size       = "s-4vcpu-8gb-amd"
    auto_scale = true
    min_nodes  = 5
    max_nodes  = 7
  }
}

# Create a new container registry
resource "digitalocean_container_registry" "abhi-playground-cr" {
  name                   = "abhi-playground-cr"
  subscription_tier_slug = "basic"
}
