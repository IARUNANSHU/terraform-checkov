resource "google_project_service" "gcp_secret_manager_api" {
  project = var.project
  service = "secretmanager.googleapis.com"
}