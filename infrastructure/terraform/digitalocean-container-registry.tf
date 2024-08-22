# Create a new container registry
resource "digitalocean_container_registry" "registry" {
  count                  = var.enable_container_registry ? 1 : 0
  name                   = var.container_registry_name
  subscription_tier_slug = "basic"
  region                 = "ams3"
}