resource "local_file" "master_vars_with_cvs" {

  count = var.cvs_available[var.region] ? 1 : 0

  filename = "../../../env-config/${var.env}/${var.customer}_${var.env}_master_vars.yml"
  content = templatefile("../templates/master_vars.yml", {

    local-file-zone            = local.zonea
    local-file-region          = var.region
    local-file-project_id      = var.project
    local-file-env             = var.env
    local-file-customer        = var.customer
    local-file-regional        = local.regional
    local-file-cluster_name    = local.cluster_name
    local-file-cvoSize         = "NA"
    local-file-cvoSubnet       = "NA"
    local-file-cvoZone         = "NA"
    local-file-trident_version = "NA"
    local-file-upgrade_trident = "NA"
    local-file-typeofdns       = var.dns_type
    local-file-typeofcert      = var.cert_type
    local-file-san_required    = var.san_required
    local-file-san_dns         = var.san_dns
    local-file-cvo_required    = "false"
    local_file_product         = var.product
    local_prometheus_ip        = google_compute_address.internal_ip_prometheus.address
    local_grafana_ip           = google_compute_address.internal_ip_grafana.address
    local_alertmanager_ip      = google_compute_address.internal_ip_alertmanager.address
    cvs_server_ip              = netapp-gcp_volume.cvs-volume[count.index].mount_points[0].server
    cvs_export_path            = netapp-gcp_volume.cvs-volume[count.index].mount_points[0].export
    csi_driver_nfs_version     = var.csi_driver_nfs_version
    sc_reclaim_policy          = "Retain"
    sc_volume_binding_mode     = "Immediate"
  })
}

resource "local_file" "master_vars_with_cvo" {

  count = var.cvs_available[var.region] ? 0 : 1

  filename = "../../../env-config/${var.env}/${var.customer}_${var.env}_master_vars.yml"
  content = templatefile("../templates/master_vars.yml", {

    local-file-zone            = local.zonea
    local-file-region          = var.region
    local-file-project_id      = var.project
    local-file-env             = var.env
    local-file-customer        = var.customer
    local-file-regional        = local.regional
    local-file-cluster_name    = local.cluster_name
    local-file-cvoSize         = var.trident_cvo_size
    local-file-cvoSubnet       = var.subnetwork
    local-file-cvoZone         = "a"
    local-file-trident_version = var.trident_version
    local-file-upgrade_trident = var.upgrade_trident
    local-file-typeofdns       = var.dns_type
    local-file-typeofcert      = var.cert_type
    local-file-san_required    = var.san_required
    local-file-san_dns         = var.san_dns
    local-file-cvo_required    = var.cvo_required
    local_file_product         = var.product
    local_prometheus_ip        = google_compute_address.internal_ip_prometheus.address
    local_grafana_ip           = google_compute_address.internal_ip_grafana.address
    local_alertmanager_ip      = google_compute_address.internal_ip_alertmanager.address
    cvs_server_ip              = "NA"
    cvs_export_path            = "NA"
    csi_driver_nfs_version     = "NA"
    sc_reclaim_policy          = "NA"
    sc_volume_binding_mode     = "NA"
  })
}

resource "local_file" "customer_readme_for_cvs" {

  count = var.cvs_available[var.region] ? 1 : 0

  filename = "../../../env-config/${var.env}/Deployment-View.md"
  content = templatefile("../templates/README.md", {
    local_file_customer              = var.customer
    local_file_env                   = var.env
    local_file_project               = var.project
    local_file_region                = var.region
    local_file_product               = var.product_details
    local_file_product_version       = var.product_version
    local_file_deployment_size       = var.deployment_size
    deployment_tier                  = var.deployment_tier
    subnetwork                       = var.subnetwork
    ip_range_services_name           = var.ip_range_services
    master_ipv4_cidr_block           = var.master_ipv4
    node_machine_type                = var.node_machine_type
    app_dns                          = var.env == "prod" ? var.customer : "${var.customer}-${var.env}"
    local_cluster_name               = local.cluster_name
    local_namespace_name             = local.namespace_name
    local_postgres_server            = jsonencode(module.sql-db_postgresql[*].instance_ip_address)
    local_gcloud_command             = local.regional == true ? "gcloud container clusters get-credentials ${local.cluster_name} --region ${var.region} --project ${var.project}" : "gcloud container clusters get-credentials ${local.cluster_name} --zone ${local.zonea} --project ${var.project}"
    local_customization              = var.customization_details
    local_csd11_link                 = var.csd11_link[var.product_version]
    local_deployment_rhel_jumpbox    = var.deployment_rhel_jumpbox[var.region]
    local_deployment_windows_jumpbox = var.deployment_windows_jumpbox[var.region]
    local_location                   = var.env == "prod" ? var.region : local.zonea
    local_access_type                = var.access_type
    local_velero_version             = var.velero_version
    local_kube_prometheus_version    = var.kube_prometheus_version
    local_ingress_nginx_version      = var.ingress_nginx_version
    local_trident_version            = "NA"
    cvs_name                         = local.cvs_name
    cvs_server_ip                    = netapp-gcp_volume.cvs-volume[count.index].mount_points[0].server
    cvs_vol_size                     = var.cvs_size
    csi_driver_nfs_version           = var.csi_driver_nfs_version
  })
}

resource "local_file" "customer_readme_for_cvo" {

  count = var.cvs_available[var.region] ? 0 : 1

  filename = "../../../env-config/${var.env}/Deployment-View.md"
  content = templatefile("../templates/README.md", {
    local_file_customer              = var.customer
    local_file_env                   = var.env
    local_file_project               = var.project
    local_file_region                = var.region
    local_file_product               = var.product_details
    local_file_product_version       = var.product_version
    local_file_deployment_size       = var.deployment_size
    deployment_tier                  = var.deployment_tier
    subnetwork                       = var.subnetwork
    ip_range_services_name           = var.ip_range_services
    master_ipv4_cidr_block           = var.master_ipv4
    node_machine_type                = var.node_machine_type
    app_dns                          = var.env == "prod" ? var.customer : "${var.customer}-${var.env}"
    local_cluster_name               = local.cluster_name
    local_namespace_name             = local.namespace_name
    local_postgres_server            = jsonencode(module.sql-db_postgresql[*].instance_ip_address)
    local_gcloud_command             = local.regional == true ? "gcloud container clusters get-credentials ${local.cluster_name} --region ${var.region} --project ${var.project}" : "gcloud container clusters get-credentials ${local.cluster_name} --zone ${local.zonea} --project ${var.project}"
    local_customization              = var.customization_details
    local_csd11_link                 = var.csd11_link[var.product_version]
    local_deployment_rhel_jumpbox    = var.deployment_rhel_jumpbox[var.region]
    local_deployment_windows_jumpbox = var.deployment_windows_jumpbox[var.region]
    local_location                   = var.env == "prod" ? var.region : local.zonea
    local_access_type                = var.access_type
    local_velero_version             = var.velero_version
    local_kube_prometheus_version    = var.kube_prometheus_version
    local_ingress_nginx_version      = var.ingress_nginx_version
    local_trident_version            = var.trident_version
    cvs_name                         = "NA"
    cvs_server_ip                    = "NA"
    cvs_vol_size                     = "NA"
    csi_driver_nfs_version           = "NA"
  })
}