#locals {
#  prometheus_dns_records = [
#    "grafana-${var.customer}-${var.env}",
#    "alertmanager-${var.customer}-${var.env}",
#    "prometheus-${var.customer}-${var.env}"
#  ]
#}

data "google_compute_subnetwork" "subnet" {
  name    = var.subnetwork
  project = var.network_project_id
}

## External IP for the APP GKE LB
resource "google_compute_global_address" "default" {
  project      = var.project
  name         = local.externalip_name
  description  = local.externalip_description
  address_type = "EXTERNAL"
}

## Internal IP for Prometheus
resource "google_compute_address" "internal_ip_prometheus" {
  project      = var.project
  name         = "${var.customer}-${var.env}-prometheus"
  description  = "${var.customer}-${var.env} prometheus - Managed by Terraform"
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.subnet.id
}

## Internal IP for Grafana
resource "google_compute_address" "internal_ip_grafana" {
  project      = var.project
  name         = "${var.customer}-${var.env}-grafana"
  description  = "${var.customer}-${var.env} grafana - Managed by Terraform"
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.subnet.id
}

## Internal IP for Alert Manager
resource "google_compute_address" "internal_ip_alertmanager" {
  project      = var.project
  name         = "${var.customer}-${var.env}-alertmanager"
  description  = "${var.customer}-${var.env} alertmanager - Managed by Terraform"
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.subnet.id
}

# DNS record for External IP for the App
resource "dns_a_record_set" "app_external_dns_record" {
  provider  = dns.external_dns
  zone      = "opentext.cloud."
  name      = var.env == "prod" ? "*.${var.customer}" : "*.${var.customer}-${var.env}"
  addresses = [google_compute_global_address.default.address]
}

# DNS record for Prometheus
resource "dns_a_record_set" "internal_ip_prometheus_dns_record" {
  #for_each  = toset(local.prometheus_dns_records)
  zone      = "${var.dns_zone}."
  name      = "prometheus-${var.customer}-${var.env}"
  addresses = [google_compute_address.internal_ip_prometheus.address]
}

# DNS record for Grafana
resource "dns_a_record_set" "internal_ip_grafana_dns_record" {
  #for_each  = toset(local.prometheus_dns_records)
  zone      = "${var.dns_zone}."
  name      = "grafana-${var.customer}-${var.env}"
  addresses = [google_compute_address.internal_ip_grafana.address]
}

# DNS record for Alertmanager
resource "dns_a_record_set" "internal_ip_alertmanager_dns_record" {
  #for_each  = toset(local.prometheus_dns_records)
  zone      = "${var.dns_zone}."
  name      = "alertmanager-${var.customer}-${var.env}"
  addresses = [google_compute_address.internal_ip_alertmanager.address]
}
