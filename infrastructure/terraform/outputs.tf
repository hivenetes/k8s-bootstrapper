# ============================== DOKS ==============================
output "cluster_id" {
  value = digitalocean_kubernetes_cluster.bootstrapper.id
}

output "cluster_name" {
  value = digitalocean_kubernetes_cluster.bootstrapper.name
}

# ======================= DIGITALOCEAN DATABASES =========================
output "database_uri" {
  value = var.enable_databases ? digitalocean_database_cluster.bootstrapper[0].uri : null
  description = "Database URI"
  sensitive = true
}

output "database_host" {
  value = var.enable_databases ? digitalocean_database_cluster.bootstrapper[0].host : null
  description = "Database host"
}

output "database_port" {
  value = var.enable_databases ? digitalocean_database_cluster.bootstrapper[0].port : null
  description = "Database port"
}

output "database_name" {
  value = var.enable_databases ? digitalocean_database_cluster.bootstrapper[0].database : null
  description = "Database name"
}

output "database_user" {
  value = var.enable_databases ? digitalocean_database_cluster.bootstrapper[0].user : null
  description = "Database user"
}

output "database_password" {
  value = var.enable_databases ? digitalocean_database_cluster.bootstrapper[0].password : null
  description = "Database password"
  sensitive = true
}

# ================================== ARGOCD ==================================
output "argocd_helm_chart_values" {
  value = helm_release.argocd[0].values
}

output "argocd_helm_chart_manifest" {
  value = helm_release.argocd[0].manifest
}