locals {
  cluster_name = "innovation-vbt-01"
}

# DigitalOcean variables
variable "do_token" {
  type = string 
  description = "The DigitalOcean API token"
}

variable "access_key" {
  type = string
  description = "The access key for the S3 bucket"
}

variable "secret_key" {
  type = string
  description = "The secret key for the S3 bucket"
}


# Application variables 
variable "environment" {
  description = "Environnement de déploiement (ex: dev, staging, prod)"
  type        = string
  default     = "dev"
}


module "doks-cluster" {
  source             = "./doks-cluster"
  cluster_name       = local.cluster_name
  cluster_region     = "tor1"
  cluster_version    = "1.33.1-do.4"
  worker_size        = "s-2vcpu-4gb"
  worker_count       = 3
  projet_name        = "innovation"
  domain_name        = "${local.cluster_name}.testnv.ca"
}

module "kubernetes-config" {
  source      = "./kubernetes-config"
  cluster_name = module.doks-cluster.cluster_name
  domain_name = module.doks-cluster.domain_name
  domain_id   = module.doks-cluster.domain_id
  do_token    = var.do_token
}
