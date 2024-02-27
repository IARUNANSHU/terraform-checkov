locals {
  cluster_resource_labels = merge(
  local.additional_labels,
  {
    customer    = var.customer,
    environment = var.env,
  }
  )
}

module "kubernetes-engine_private-cluster" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "25.0.0"

  # Start editing below this line
  project_id                    = var.project
  name                          = local.cluster_name
  region                        = var.region
  zones                         = var.env == "prod" ? [local.zonea, local.zoneb, local.zonec] : [local.zonea]
  network_project_id            = var.network_project_id
  network                       = var.network
  subnetwork                    = var.subnetwork
  ip_range_pods                 = var.ip_range_pods
  ip_range_services             = var.ip_range_services
  http_load_balancing           = var.http_lb
  configure_ip_masq             = var.ip_masq
  non_masquerade_cidrs          = var.non_masq_cidrs
  horizontal_pod_autoscaling    = var.horizontal_autoscaling
  network_policy                = var.network_policy
  master_ipv4_cidr_block        = var.master_ipv4
  master_authorized_networks    = var.master_authorized_networks
  regional                      = var.env == "prod" ? true : false
  kubernetes_version            = var.cluster_version
  create_service_account        = var.create_sa
  enable_private_endpoint       = var.enable_private_endpoint
  enable_private_nodes          = var.enable_private_nodes
  enable_binary_authorization   = var.enable_binary_authorization
  remove_default_node_pool      = var.remove_default_node_pool
  skip_provisioners             = var.skip_provisioners
  deploy_using_private_endpoint = var.deploy_using_private_endpoint
  cluster_resource_labels       = local.cluster_resource_labels
  monitoring_enable_managed_prometheus = var.monitoring_enable_managed_prometheus
  monitoring_enabled_components = ["SYSTEM_COMPONENTS","APISERVER","SCHEDULER","CONTROLLER_MANAGER"]
  
  

  node_pools = [
    {
      name               = local.node_pool_name
      machine_type       = local.infra_specs[var.env][var.deployment_size].node_machine_type
      initial_node_count = local.infra_specs[var.env][var.deployment_size].gke_num_nodes
      node_count         = local.infra_specs[var.env][var.deployment_size].gke_num_nodes
      disk_size_gb       = var.disk_size
      disk_type          = var.env == "prod" ? "pd-ssd" : "pd-balanced"
      image_type         = var.image_type
      auto_repair        = var.auto_repair
      auto_upgrade       = var.auto_upgrade
      autoscaling        = var.autoscaling
      preemptible        = var.preemptible
    },
  ]

  node_pools_tags = {
    all = local.network_tags

    default-node-pool = [
      "default-node-pool",
    ]
  }
}
