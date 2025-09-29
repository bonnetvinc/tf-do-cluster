variable "cluster_version" {
  type = string
  description = "The version of the Kubernetes cluster, please see https://slugs.do-api.dev/ for slugs"
}

variable "projet_name" {
  type = string
  description = "The name of the project in DigitalOcean where the Kubernetes cluster will be created"
  default = "Innovation NoName"
}

variable "worker_count" {
  type = number
  description = "The number of worker nodes in the Kubernetes cluster"
}

variable "worker_size" {
  type = string
  description = "The size of the worker nodes (e.g. s-2vcpu-4gb)"
}

variable "cluster_name" {
  type = string
  description = "The name of the Kubernetes cluster"
}

variable "cluster_region" {
  type = string
  description = "The region where the Kubernetes cluster will be created (e.g. nyc1, sfo2, etc.), see https://www.digitalocean.com/docs/platform/availability-matrix/ for available regions"
}

variable "domain_name" {
  type = string
  description = "Domain name to create in DigitalOcean DNS (e.g. example.com)"
}