output "cluster_id" {
  value = digitalocean_kubernetes_cluster.primary.id
}

output "cluster_name" {
  value = digitalocean_kubernetes_cluster.primary.name
}

output "kubeconfig" {
  description = "Kubeconfig du cluster DOKS"
  value       = digitalocean_kubernetes_cluster.primary.kube_config[0].raw_config
  sensitive   = true
}

output "domain_name" {
  description = "Nom du domaine créé"
  value       = digitalocean_domain.main.name
}

output "domain_id" {
  description = "ID du domaine pour les enregistrements DNS"
  value       = digitalocean_domain.main.id
}