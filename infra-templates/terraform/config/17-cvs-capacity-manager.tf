# data "google_project" "project" {
#     project_id = var.project
# }

# resource "google_service_account" "cvs-svc-account" {
#   count = var.cvs_available[var.region] ? 1 : 0
#   project    = var.project
#   account_id = "svc-otc-${var.customer}-cvs-${var.env}"
# }

# resource "google_project_iam_custom_role" "cvs-autoexpand-gcp-role" {

#   count = var.cvs_available[var.region] ? 1 : 0

#   project = var.project
#   role_id     = "cvs_autoexpand_gcp_role_${var.customer}"
#   title       = "${var.customer} CVS Autoexpand GCP role"
#   description = "Role Assigned to CVS service account to automatically expand the volume"
#   permissions = [ 
#     "cloudvolumesgcp-api.netapp.com/volumes.create", 
#     "cloudvolumesgcp-api.netapp.com/volumes.get",
#     "cloudvolumesgcp-api.netapp.com/volumes.list",
#     "cloudvolumesgcp-api.netapp.com/volumes.update",
#     # signJWT Role permissions
#      "iam.serviceAccounts.get", 
#      "iam.serviceAccounts.getAccessToken", 
#      "iam.serviceAccounts.getOpenIdToken", 
#      "iam.serviceAccounts.implicitDelegation", 
#      "iam.serviceAccounts.list", 
#      "iam.serviceAccounts.signBlob", 
#      "iam.serviceAccounts.signJwt"
#     ]
# }

# resource "google_project_iam_member" "cvs-autoexpand" {

#   count = var.cvs_available[var.region] ? 1 : 0

#   project = var.project
#   role    = "projects/${var.project}/roles/${google_project_iam_custom_role.cvs-autoexpand-gcp-role[count.index].role_id}"
#   member  = "serviceAccount:${google_service_account.cvs-svc-account[count.index].email}"
# }

# # resource "google_pubsub_topic" "CVSCapacityManagerEvents" {

# #   count = var.cvs_available[var.region] ? 1 : 0
# #   kms_key_name = google_kms_crypto_key.crypto_key.id
# #   project = var.project
# #   name = "${var.customer}-${var.env}-CVS-Capacity-Manager-Topic"
# # }

# # Monitoring Service Account is created after first Alerting Policy is created
# # Creation is eventually consistent, so we wait some time for Google to creat it
# resource "time_sleep" "wait_30_seconds" {
#   create_duration = "30s"
# }


# resource "google_pubsub_topic_iam_binding" "pubsub_monitoring_sa_binding" {

#   count = var.cvs_available[var.region] ? 1 : 0

#   project = var.project
#   topic = google_pubsub_topic.CVSCapacityManagerEvents[count.index].name
#   role = "roles/pubsub.publisher"
#   members = ["serviceAccount:service-${data.google_project.project.number}@gcp-sa-monitoring-notification.iam.gserviceaccount.com"]

#   depends_on = [ time_sleep.wait_30_seconds ]
# }

# # Create Cloud Monitoring notification channel
# resource "google_monitoring_notification_channel" "cvs-pubsub-channel" {

#   count = var.cvs_available[var.region] ? 1 : 0

#   display_name = "[${var.customer}][${var.env}] Pub/Sub Notification Channel"
#   project = var.project
#   type         = "pubsub"
#   labels = {
#     topic = google_pubsub_topic.CVSCapacityManagerEvents[count.index].id
#   }
# }

# resource "google_cloudfunctions2_function" "cvs-function" {

#   count = var.cvs_available[var.region] ? 1 : 0

#   name        = "${var.customer}-${var.env}-CVSCapacityManager"
#   description = "Cloud Function to expand the CVS volume triggered by cloud monitoring alert"
#   project = var.project
#   location = var.region
#   build_config {
#     runtime   = "python39"
#     entry_point = "CVSCapacityManager_alert_event"
#     source {
#       storage_source {
#         bucket = "gcf-code-cvs" # Currently in dryrun project. It will be moved to otc-ems-service project for customer builds
#         object = "GCP-CVS-CapacityManager.zip"
#       }
#     }
#   }

#   service_config {
#     max_instance_count = 1
#     available_memory = "128Mi"
#     timeout_seconds = 60
#     service_account_email = google_service_account.cvs-svc-account[count.index].email
#     environment_variables = {
#         CVS_CAPACITY_MARGIN = "${local.cvs_capacity_margin}"
#         SERVICE_ACCOUNT_CREDENTIAL = google_service_account.cvs-svc-account[count.index].email
#         CUSTOMER = var.customer
#         ENV = var.env
#     }
#   }

#   event_trigger {
#     event_type = "google.cloud.pubsub.topic.v1.messagePublished"
#     pubsub_topic = google_pubsub_topic.CVSCapacityManagerEvents[count.index].id
#     retry_policy = "RETRY_POLICY_DO_NOT_RETRY"
#     trigger_region = var.region
#   }

#   labels = {
#     customer = var.customer
#     env = var.env
#   }
# }
