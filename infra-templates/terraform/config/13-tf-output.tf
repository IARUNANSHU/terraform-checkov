output "cluster_endpoint" {
  value     = module.kubernetes-engine_private-cluster.endpoint
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = module.kubernetes-engine_private-cluster.ca_certificate
  sensitive = true
}
