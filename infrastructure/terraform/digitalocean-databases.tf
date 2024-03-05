
locals {
  database_cluster_name = "${var.database_cluster_name_prefix}-${var.database_cluster_engine}-${var.database_cluster_region}-${random_id.cluster_name.hex}"
}

# https://docs.digitalocean.com/reference/terraform/reference/resources/database_cluster/
# It creates a default database called defaultdb and a default user called doadmin
resource "digitalocean_database_cluster" "bootstrapper" {
    count      = var.enable_databases ? 1 : 0
    name       = local.database_cluster_name
    engine     = var.database_cluster_engine
    version    = var.database_cluster_version
    region     = var.database_cluster_region
    size       = var.database_cluster_size
    node_count = var.database_cluster_node_count
}
