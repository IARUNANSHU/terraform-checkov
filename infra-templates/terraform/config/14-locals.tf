locals {

  zonea                  = "${var.region}-a"
  zoneb                  = "${var.region}-b"
  zonec                  = "${var.region}-c"
  network_tags           = ["gke", var.region, var.env, var.customer,"${var.customer}-${var.env}"]
  node_pool_name         = "otc-ems-${var.customer}-${var.env}-node-pool-1"
  externalip_name        = "${var.customer}-${var.env}"
  externalip_description = "${var.customer}-${var.env}"
  regional               = var.env == "prod" ? true : false
  cluster_name           = var.dryrun == true ? "${var.project}-${var.customer}" : "${var.project}-${var.env}"
  namespace_name         = var.env == "prod" ? var.customer : "${var.customer}-${var.env}"
  additional_labels = {
    product         = var.product
    product_version = replace(var.product_version, ".", "_")
  }
}