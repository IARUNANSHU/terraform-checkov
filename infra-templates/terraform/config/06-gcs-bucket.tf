resource "google_storage_bucket" "gcsbucket1" {
  name          = "otc-ems-${var.customer}-${var.env}1" #Change as required
  location      = var.region
  storage_class = var.storage_class
  #bucket_policy_only = false #you can't use bucket policy only if using uniform_bucket_level access
  uniform_bucket_level_access = var.uniform_bucket_level_access # most OT applications require this option altough not recommended
  labels = {
    customer    = var.customer
    environment = var.env
  }

  public_access_prevention = "enforced"

  versioning {
    enabled = true
  }
  
 logging {
    log_bucket = "otc-ems-${var.customer}-${var.env}1-logs"
    
  }
  
  
 }

resource "google_service_account" "gcs-svc-account" {
  project    = var.project
  account_id = "svc-otc-${var.customer}-gcs-${var.env}"
}

resource "google_project_iam_member" "object_viewer_gcs-svc-account" {
  project = var.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gcs-svc-account.email}"

}

resource "google_project_iam_member" "object_vieweremsproject_gcs-svc-account" {
  project = var.emsproject
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gcs-svc-account.email}"
}
resource "google_project_iam_member" "log_writer_gcs-svc-account" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gcs-svc-account.email}"
}
resource "google_project_iam_member" "metric_writer_gcs-svc-account" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gcs-svc-account.email}"
}

resource "google_storage_bucket_iam_member" "gcs-svc-member" {
  bucket = google_storage_bucket.gcsbucket1.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.gcs-svc-account.email}"
}
