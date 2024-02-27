resource "google_project_iam_custom_role" "storage-ansible-gcp-role" {
  count       = var.cvo_required && var.cvs_available[var.region] == false ? 1 : 0
  role_id     = "storage_ansible_gcp_role_${var.customer}"
  title       = "${var.customer} Storage Ansible GCP role"
  description = "Role Assigned to Storage Ansible Account to create GKE secret for trident credentials"
  permissions = ["secretmanager.secrets.create", "secretmanager.versions.add"]
}

resource "google_project_iam_member" "svc-otc-storage-ansible" {
  count   = var.cvo_required && var.cvs_available[var.region] == false ? 1 : 0
  project = var.project
  role    = "projects/${var.project}/roles/${google_project_iam_custom_role.storage-ansible-gcp-role[count.index].role_id}"
  member  = "serviceAccount:svc-otc-storage-ansible@otc-vpc-shared.iam.gserviceaccount.com"
}