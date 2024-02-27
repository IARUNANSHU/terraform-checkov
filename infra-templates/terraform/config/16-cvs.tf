## NetApp Cloud Volume Service ##

resource "google_project_service" "gcp_cvs_api" {
  project = var.project
  service = "cloudvolumesgcp-api.netapp.com"
  disable_on_destroy = false
}

data "google_project" "vpc_project" {
  project_id = var.shared_vpc_project
}

# data "netapp-gcp_volume" "cvs-data-volume" {

#   count = var.build_cvs ? 0 : 1

#   depends_on = [
#     google_project_service.gcp_cvs_api
#   ]

#   name = local.cvs_name
#   region = var.region
# }

resource "netapp-gcp_volume" "cvs-volume" {

  count = var.cvs_available[var.region] ? 1 : 0

  depends_on = [
    google_project_service.gcp_cvs_api
  ]

  name = local.cvs_name
  volume_path = "${var.customer}-${var.env}"
  region = var.region
  protocol_types = ["NFSv3", "NFSv4"]
  network = var.network
  shared_vpc_project_number = data.google_project.vpc_project.number
  # size = var.build_cvs ? local.cvs_size_specs[var.env][var.cvs_size].size : (var.cvs_size_override ? var.cvs_custom_size : data.netapp-gcp_volume.cvs-data-volume[0].size)
  size = var.cvs_size
  service_level = var.cvs_service_level
  snapshot_directory = true

  snapshot_policy {
    enabled = true

    hourly_schedule {
      snapshots_to_keep = var.env == "prod" ? 48 : 0
    }
    daily_schedule {
      snapshots_to_keep = var.env == "prod" ?  30 : 5
      hour = 0
      minute = 0
    }
    weekly_schedule {
      snapshots_to_keep = var.env == "prod" ?  12 : 0
      day = "Sunday"
    }
  }

  export_policy {
    rule {
      allowed_clients = data.google_compute_subnetwork.subnet.ip_cidr_range
      access= "ReadWrite"
      nfsv3 {
        checked =  true
      }
      nfsv4 {
        checked = true
      }
    }    

    rule {
      # SFTP in zone-a
      allowed_clients = var.sftp_machines_zone_a_ip[var.region] == "NA" ? data.google_compute_subnetwork.subnet.ip_cidr_range : "${var.sftp_machines_zone_a_ip[var.region]}/32"
      access="ReadWrite"
      has_root_access = true
      nfsv3 {
        checked =  true
      }
      nfsv4 {
        checked = true
      }
    }

    rule {
      # SFTP in zone-b
      allowed_clients = var.sftp_machines_zone_b_ip[var.region] == "NA" ? data.google_compute_subnetwork.subnet.ip_cidr_range : "${var.sftp_machines_zone_b_ip[var.region]}/32"
      access="ReadWrite"
      has_root_access = true
      nfsv3 {
        checked =  true
      }
      nfsv4 {
        checked = true
      }
    }


  #  rule {
  #     # Jumpbox
  #     allowed_clients = "10.212.160.12/32"
  #     access="ReadWrite"
  #     has_root_access = true
  #     nfsv3 {
  #       checked =  true
  #     }
  #     nfsv4 {
  #       checked = true
  #     }
  #   }
  }
  billing_label {
    key = "customer"
    value = var.customer
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Setup Alerts
data "google_monitoring_notification_channel" "navratan" {
  display_name = "Navratan"
}

# resource "google_monitoring_notification_channel" "cloudops_email1" {
#   display_name = "[${var.customer}][${var.env}] CloudOps Email Notification Channel 1"
#   type         = "email"
#   labels       = {
#     email_address = "cloudops-platform-provisioning@opentext.com"
#   }
# }

# resource "google_monitoring_notification_channel" "cloudops_email2" {
#   display_name = "[${var.customer}][${var.env}] CloudOps Email Notification Channel 2"
#   type         = "email"
#   labels       = {
#     email_address = "cloudops-platform-operations@opentext.com"
#   }
# }

# resource "google_monitoring_notification_channel" "cloudops_ems_pagerduty" {
#   display_name = "[${var.customer}][${var.env}] CloudOps EMS Pagerduty Notification Channel"
#   type         = "pagerduty"
#   sensitive_labels {
#     service_key = "R02CQHSLS6ZG8HMQ3RI3G85G61I4FNOO"
#   }
# }

# Alert when CVS utilization reaches threshold value
resource "google_monitoring_alert_policy" "netapp_cvs_monitor_alert_policy_vol_util_warn" {

  count = var.cvs_available[var.region] ? 1 : 0

  display_name = "[${var.customer}][${var.env}][WARN] CVS volume utilization above ${local.cvs_volume_usage_warning_threshold}%"
  project      = var.project
  combiner     = "OR"
  conditions {
    display_name = "[${var.customer}][${var.env}][WARN] CVS volume utilization above ${local.cvs_volume_usage_warning_threshold}%"
    condition_threshold {
      filter          = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/volume_percent_used\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
      threshold_value = "${local.cvs_volume_usage_warning_threshold}"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  user_labels = {
    "severity": "warning",
  }
  #  notification_channels = concat (google_monitoring_notification_channel.email1.*.id, google_monitoring_notification_channel.email2.*.id, google_monitoring_notification_channel.pagerduty.*.id)
  notification_channels = [data.google_monitoring_notification_channel.navratan.name]
  documentation {
        content = "Usage of CVS volume exceeded ${local.cvs_volume_usage_warning_threshold}%. Volume will be auto-expanded at ${local.cvs_volume_expansion_threshold}% utilization."
    }
}

# Alert when CVS utilization reaches threshold value to auto-expand
# resource "google_monitoring_alert_policy" "netapp_cvs_monitor_alert_policy_vol_util_critical" {

#   count = var.cvs_available[var.region] ? 1 : 0

#   display_name = "[${var.customer}][${var.env}][WARN] CVS volume utilization above ${local.cvs_volume_expansion_threshold}%"
#   project      = var.project
#   combiner     = "OR"
#   conditions {
#     display_name = "[${var.customer}][${var.env}][WARN] CVS volume utilization above ${local.cvs_volume_expansion_threshold}%"
#     condition_threshold {
#       filter          = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/volume_percent_used\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
#       threshold_value = "${local.cvs_volume_expansion_threshold}"
#       duration        = "60s"
#       comparison      = "COMPARISON_GT"
#       aggregations {
#         alignment_period   = "60s"
#         per_series_aligner = "ALIGN_MEAN"
#       }
#     }
#   }

#   user_labels = {
#     "severity": "warning",
#   }
  #  notification_channels = concat (google_monitoring_notification_channel.email1.*.id, google_monitoring_notification_channel.email2.*.id, google_monitoring_notification_channel.pagerduty.*.id, google_monitoring_notification_channel.cvs-pubsub-channel.name)
  # notification_channels = [data.google_monitoring_notification_channel.navratan.name, google_monitoring_notification_channel.cvs-pubsub-channel[count.index].name]
  # documentation {
  #       content = "Usage of CVS volume exceeded ${local.cvs_volume_expansion_threshold}%. Volume will be auto-expanded by Cloud Function (GCP-CVS-CapacityManager)."
  #   }
# }

# Metric dashboard
resource "google_monitoring_alert_policy" "netapp_cvs_monitor_alert_policy1" {

  count = var.cvs_available[var.region] ? 1 : 0

  display_name = "[${var.customer}][${var.env}] Netapp CVS Monitor Alert Policy 1"
  project      = var.project
  combiner     = "OR"

  conditions {
    display_name = "[${var.customer}][${var.env}] Netapp CVS Volume Read Bytes Count"
    condition_threshold {
      filter     = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/read_bytes_count\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
      duration   = "60s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "[${var.customer}][${var.env}] Netapp CVS Volume Write Bytes Count"
    condition_threshold {
      filter     = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/write_bytes_count\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
      duration   = "60s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "[${var.customer}][${var.env}] Netapp CVS Volume Operations Count"
    condition_threshold {
      filter     = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/operation_count\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
      duration   = "60s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "[${var.customer}][${var.env}] Netapp CVS Volume Inode Allocation"
    condition_threshold {
      filter     = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/inode_allocation\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
      duration   = "60s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "[${var.customer}][${var.env}] Netapp CVS Volume Inode Usage"
    condition_threshold {
      filter     = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/inode_usage\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
      duration   = "60s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "[${var.customer}][${var.env}] Netapp CVS Volume IO operation latency"
    condition_threshold {
      filter     = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/request_latencies\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
      duration   = "60s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
      }
    }
  }
}

resource "google_monitoring_alert_policy" "netapp_cvs_monitor_alert_policy2" {

  count = var.cvs_available[var.region] ? 1 : 0

  display_name = "[${var.customer}][${var.env}] Netapp CVS Monitor Alert Policy 2"
  project = var.project
  combiner = "OR"

  conditions {
    display_name = "[${var.customer}][${var.env}] Netapp CVS Volume space allocation"
    condition_threshold {
      filter = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/volume_size\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
      duration = "60s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  
  conditions {
    display_name = "[${var.customer}][${var.env}] Netapp CVS Volume space usage"
    condition_threshold {
      filter = "metric.type=\"cloudvolumesgcp-api.netapp.com/cloudvolume/volume_usage\" AND resource.type=\"cloudvolumesgcp-api.netapp.com/CloudVolume\" AND resource.label.\"name\"=\"${local.cvs_name}\""
      duration = "60s"
      comparison = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
}
