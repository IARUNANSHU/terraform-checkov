#PROVIDER DEFINITIONS
terraform {
  # required_version = "=1.3.6"
  # backend "gcs" {

  # }
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    netapp-gcp = {
      source = "NetApp/netapp-gcp"
      version = "23.4.0"
    }

  }
}

provider "google" {
  project     = var.project
  region      = var.region
  zone        = local.zonea
  credentials = "../../../terraform_key.json"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  config_path            = "~/.kube/config"
  host                   = "https://${module.kubernetes-engine_private-cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.kubernetes-engine_private-cluster.ca_certificate)

}

data "google_secret_manager_secret_version" "cloud_ops_ems_dns_key" {
  secret  = "Infoblox_TSIG_key"
  project = "terr-basic"
}

provider "dns" {
  update {
    server        = "lit-idns-p001.gxsonline.net"
    key_name      = "cloud_ops_ems."
    key_algorithm = "hmac-sha256"
    key_secret    = data.google_secret_manager_secret_version.cloud_ops_ems_dns_key.secret_data
  }
}

provider "dns" {
  alias = "external_dns"
  update {
    server        = "lit-edns-p001.gxsonline.net"
    key_name      = "cloud_ops_ems."
    key_algorithm = "hmac-sha256"
    key_secret    = data.google_secret_manager_secret_version.cloud_ops_ems_dns_key.secret_data
  }
}

provider "netapp-gcp" {
  project         = var.project
  service_account = var.service_account
}
