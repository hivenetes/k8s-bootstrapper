output "cluster_id" {
  value = digitalocean_kubernetes_cluster.bootstrapper.id
}

output "cluster_name" {
  value = digitalocean_kubernetes_cluster.bootstrapper.name
}

output "argocd_helm_chart_values" {
  value = helm_release.argocd[0].values
}

output "argocd_helm_chart_manifest" {
  value = helm_release.argocd[0].manifest
}