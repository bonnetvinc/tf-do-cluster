resource "helm_release" "external_dns" {
  name             = "external-dns"
  repository       = "https://kubernetes-sigs.github.io/external-dns/"
  chart            = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  set = [
    {
      name  = "provider"
      value = "godaddy"
    },
  ]
}
variable "cluster_name" {
  type = string
}

variable "domain_name" {
  type        = string
  description = "Nom du domaine à configurer"
}

variable "domain_id" {
  type        = string
  description = "ID du domaine DigitalOcean"
}

variable "do_token" {
  type        = string
  description = "Token d'authentification DigitalOcean"
  sensitive   = true
}

data "digitalocean_kubernetes_cluster" "primary" {
  name = var.cluster_name
}

provider "digitalocean" {
  token = var.do_token
}

provider "helm" {
  kubernetes = {
    host                   = data.digitalocean_kubernetes_cluster.primary.endpoint
    token                  = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.primary.endpoint
  token                  = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate)
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  create_namespace = true

  set = [{
    name  = "controller.service.annotations.service.beta.kubernetes.io/do-loadbalancer-size-unit"
    value = "1"
  }]
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true

  values = [<<EOF
installCRDs: true
EOF
  ]
}

# Attendre que le Load Balancer soit créé et récupérer son IP
data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [helm_release.nginx_ingress]
}

# Enregistrement DNS pour le domaine racine
resource "digitalocean_record" "root" {
  domain = var.domain_id
  type   = "A"
  name   = "@"
  value  = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
  ttl    = 300
}

# Enregistrement DNS pour le sous-domaine wildcard
resource "digitalocean_record" "wildcard" {
  domain = var.domain_id
  type   = "A"
  name   = "*"
  value  = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].ip
  ttl    = 300
}