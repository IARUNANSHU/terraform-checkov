resource "netapp-gcp_volume" "additional-nfs-volume" {
  count = var.enable_additional_nfs && var.cvs_available[var.region] ? 1 : 0

  name = "${var.customer}-${var.env}-nfs"
  volume_path = "${var.customer}-${var.env}-nfs"
  region = var.region
  protocol_types = ["NFSv3", "NFSv4"]
  network = var.network
  shared_vpc_project_number = data.google_project.vpc_project.number
  size = var.additional_nfs_size
  service_level = var.additional_nfs_service_level
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
      has_root_access = true
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
rule {
      # Jumpbox
      allowed_clients = "10.212.160.12/32"
      access="ReadWrite"
      has_root_access = true
      nfsv3 {
        checked =  true
      }
      nfsv4 {
        checked = true
      }
    }
  }
  billing_label {
    key = "customer"
    value = var.customer
  }

  lifecycle {
    prevent_destroy = true
  }
}
