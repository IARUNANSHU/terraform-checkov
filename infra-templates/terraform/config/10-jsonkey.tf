resource "google_service_account_key" "jsonkey" {
  service_account_id = google_service_account.gcs-svc-account.name
  #private_key_type = "TYPE_PKCS12_FILE"
}

resource "google_secret_manager_secret" "jsonsecret" {
  secret_id = "svc-otc-${var.customer}-gcs-${var.env}-json"

  replication {
    auto {}
  }

  depends_on = [
    google_project_service.gcp_secret_manager_api
  ]
}

resource "google_secret_manager_secret_version" "jsonsecretversion" {
  secret = google_secret_manager_secret.jsonsecret.id
  secret_data = base64decode(google_service_account_key.jsonkey.private_key)

  depends_on = [
    google_project_service.gcp_secret_manager_api
  ]
}

resource "google_secret_manager_secret_iam_binding" "binding" {
  project = google_secret_manager_secret.jsonsecret.project
  secret_id = google_secret_manager_secret.jsonsecret.secret_id
  role = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:svc-ems-gke-mgmt@otc-ems-gke-mgmt.iam.gserviceaccount.com",
  ]
}