module "velero" {
  customer           = var.customer
  env                = var.env
  source             = "./module/gcp-velero"
  backup_bucket_name = "velero-${var.customer}-${var.env}"
  project            = var.project
  location           = var.region
  tags = {
    customer = var.customer
    env      = var.env
  }
  depends_on = [
    google_project_service.gcp_secret_manager_api
  ]

}
