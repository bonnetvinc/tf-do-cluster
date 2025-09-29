# Essaie de récupérer le projet existant ou le crée
data "digitalocean_project" "existing" {
  name = var.projet_name
}

resource "digitalocean_project" "project" {
  count       = length(data.digitalocean_project.existing.id) > 0 ? 0 : 1
  name        = var.projet_name
  description = "Projet pour le cluster Kubernetes ${var.cluster_name}"
  purpose     = "Web Application"
  environment = "Development"
}

locals {
  project_id = length(data.digitalocean_project.existing.id) > 0 ? data.digitalocean_project.existing.id : digitalocean_project.project[0].id
}


resource "digitalocean_kubernetes_cluster" "primary" {
  name    = var.cluster_name
  region  = var.cluster_region
  version = var.cluster_version

  node_pool {
    name       = "${var.cluster_name}-pool"
    size       = var.worker_size
    node_count = var.worker_count
  }

  # registry_integration = true
}

# Le domaine doit pointer vers le Load Balancer, pas directement vers le cluster
# On va d'abord créer le domaine sans IP, puis mettre à jour via les records DNS
resource "digitalocean_domain" "main" {
  name = var.domain_name
  # Note: On ne peut pas utiliser l'IP du cluster directement
  # Il faut récupérer l'IP du Load Balancer créé par l'ingress
}

# Les enregistrements DNS seront créés dans le module kubernetes-config
# après que le Load Balancer soit disponible

# Associe le cluster au projet
resource "digitalocean_project_resources" "cluster" {
  project = local.project_id
  resources = [
    digitalocean_kubernetes_cluster.primary.urn,
    digitalocean_domain.main.urn
  ]
}
