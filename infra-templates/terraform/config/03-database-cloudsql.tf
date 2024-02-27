#CloudSQL

module "sql-db_postgresql" {

  #https://cloud.google.com/sql/docs/postgres/instance-settings
  #https://registry.terraform.io/modules/GoogleCloudPlatform/sql-db/google/latest/submodules/postgresql
  source                          = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version                         = "11.0.0"
  database_version                = var.pg_db_version
  disk_autoresize                 = true
  name                            = "pg-db-instance-${var.customer}-${var.env}" #name needs to start with a letter
  project_id                      = var.project
  region                          = var.region
  zone                            = local.zonea
  availability_type               = var.env == "prod" ? "REGIONAL" : "ZONAL"
  tier                            = local.infra_specs[var.env][var.deployment_size].postgres_instance_type
  maintenance_window_hour         = "2"
  maintenance_window_day          = "7"
  maintenance_window_update_track = "stable"
  ip_configuration                = {
    "authorized_networks" = []
    "ipv4_enabled"        = false
    "private_network"     = data.google_compute_network.shared_network.id
    "require_ssl"         = true
    "allocated_ip_range"  = null
  }
 database_flags =  [
    {
     "name"  : "log_disconnections"
     "value" : "on"
    },
    {
     "name"  : "log_connections"
     "value" : "on"
    },
    {
     "name"  : "log_duration"
     "value" : "on"
    },
    {
     "name"  : "log_lock_waits"
     "value" : "on"
    },
    {
     "name"  : "log_checkpoints"
     "value" : "on"
    },
    {
      "name"  : "cloudsql.enable_pgaudit"
      "value" : "on"
    },
    {
      "name"  : "log_hostname"
      "value" : "on"
    },
    {
      "name"  : "log_min_error_statement"
      "value" : "error"
    },
    {
      "name"  : "log_statement"
      "value" : "all"    
    }
   ]
  disk_size            = local.infra_specs_total_db_schema.application_schema_size_total
  backup_configuration = {
    
    "enabled" : true,
    "location" : var.env == "prod" ? null : var.region,
    #Backups are stored in the closest multi-region location to you by default. Only customize if needed.
    "point_in_time_recovery_enabled" : true,
    "retained_backups" : var.env == "prod" ? 30 : 5,
    "retention_unit" : null,
    "start_time" : "23:00",
    "transaction_log_retention_days" : var.env == "prod" ? 7 : 5
  }
  additional_users = [
    {
      name     = "${var.customer}_${var.env}-admin"
      password = random_password.admin_user_password.result
    },
    {
      name     = "ac_user"
      password = random_password.ac_user_password.result
    },
    {
      name     = "awg_user"
      password = random_password.awg_user_password.result
    },
    {
      name     = "ds_user"
      password = random_password.ds_user_password.result
    }
  ]
  additional_databases = [
    {
      name      = "${var.customer}_${var.env}-admin"
      charset   = "UTF8"
      collation = "en_US.UTF8"
    },
    #    {
    #      name      = "ac_user"
    #      charset   = "UTF8"
    #      collation = "en_US.UTF8"
    #    },
    {
      name      = "ds_user"
      charset   = "UTF8"
      collation = "en_US.UTF8"
    },
    {
      name      = "awg_user"
      charset   = "UTF8"
      collation = "en_US.UTF8"
    }
  ]
  user_labels = {
    customer    = var.customer,
    environment = var.env,
    instance    = "pg-db-instance-${var.customer}-${var.env}"
  }
}

resource "random_id" "db_name_suffix" {
  
  byte_length = 4
}

resource "random_password" "admin_user_password" {
  
  length           = 30
  special          = true
  numeric          = true
  upper            = true
  override_special = "$*^-~_![]{}"
}

resource "random_password" "ac_user_password" {
  
  length           = 30
  special          = true
  numeric          = true
  upper            = true
  override_special = "@$*^-~_![]{}"
}

resource "random_password" "awg_user_password" {
  
  length           = 30
  special          = true
  numeric          = true
  upper            = true
  override_special = "$*^-~_![]{}"
}

resource "random_password" "ds_user_password" {
  
  length           = 30
  special          = true
  numeric          = true
  upper            = true
  override_special = "@$*^-~_![]{}"
}

data "google_compute_network" "shared_network" {
  name    = "terr-basic"
  project = var.network_project_id
}

#data "google_compute_subnetwork" "subnet" {
#  name    = var.subnetwork
#  project = var.network_project_id
#}

resource "google_secret_manager_secret" "pgsql_user_password" {
  
  secret_id = "${module.sql-db_postgresql.instance_name}-${var.customer}_${var.env}-admin"
  labels    = {
    customer    = var.customer,
    environment = var.env
  }
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "admin-password" {
  
  secret      = google_secret_manager_secret.pgsql_user_password.id
  secret_data = random_password.admin_user_password.result
}

resource "google_secret_manager_secret" "ac_user_password" {
  
  secret_id = "${module.sql-db_postgresql.instance_name}-ac_user"
  labels    = {
    customer    = var.customer,
    environment = var.env
  }
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ac_user_password" {
  
  secret      = google_secret_manager_secret.ac_user_password.id
  secret_data = random_password.ac_user_password.result
}

resource "google_secret_manager_secret" "awg_user_password" {
  
  secret_id = "${module.sql-db_postgresql.instance_name}-awg_user"
  labels    = {
    customer    = var.customer,
    environment = var.env
  }
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "awg_user_password" {
  
  secret      = google_secret_manager_secret.awg_user_password.id
  secret_data = random_password.awg_user_password.result
}

resource "google_secret_manager_secret" "ds_user_password" {
  
  secret_id = "${module.sql-db_postgresql.instance_name}-ds_user"
  labels    = {
    customer    = var.customer,
    environment = var.env
  }
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "ds_user_password" {
  
  secret      = google_secret_manager_secret.ds_user_password.id
  secret_data = random_password.ds_user_password.result
}

resource "google_monitoring_notification_channel" "cloudops_email" {
  
  display_name = "CloudOps Email Notification Channel"
  type         = "email"
  labels       = {
    email_address = "nadigs@opentext.com"
  }
}

resource "google_monitoring_notification_channel" "cloudops_email2" {
  
  display_name = "CloudOps Email Notification Channel 2"
  type         = "email"
  labels       = {
    email_address = "spradhan@opentext.com"
  }
}

resource "google_monitoring_alert_policy" "monitor_alert_policy1" {
  
  display_name = "CloudSQL Monitor Alert Policy 1 - pg-db-instance-${var.customer}-${var.env}"
  project      = var.project
  combiner     = "OR"
  conditions {
    display_name = "Memory Utilization"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/memory/utilization\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "0.8"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  conditions {
    display_name = "CPU Utilization"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "0.8"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  conditions {
    display_name = "Disk Utilization"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/disk/utilization\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "0.8"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Instance State"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/instance_state\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "4"
      duration        = "60s"
      comparison      = "COMPARISON_LT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_COUNT_TRUE"
      }
    }
  }

  conditions {
    display_name = "Per query execution times"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/perquery/execution_time\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "24"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  conditions {
    display_name = "Replica Lag Bytes"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/postgresql/replication/replica_byte_lag\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "100"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = concat(google_monitoring_notification_channel.cloudops_email.*.id, google_monitoring_notification_channel.cloudops_email2.*.id)
  #notification_channels = "${concat(google_monitoring_notification_channel.cloudops_email.*.id,google_monitoring_notification_channel.cloudops_csdplat_pagerduty.*.id,google_monitoring_notification_channel.cloudops_ems_pagerduty.*.id)}"
}

resource "google_monitoring_alert_policy" "monitor_alert_policy2" {
  
  display_name = "CloudSQL Monitor Alert Policy 2 - pg-db-instance-${var.customer}-${var.env}"
  project      = var.project
  combiner     = "OR"

  conditions {
    display_name = "Temporary files used for writing data"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/postgresql/temp_files_written_count\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "10"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  notification_channels = concat(google_monitoring_notification_channel.cloudops_email.*.id, google_monitoring_notification_channel.cloudops_email2.*.id)
  #notification_channels = "${concat(google_monitoring_notification_channel.cloudops_email.*.id,google_monitoring_notification_channel.cloudops_csdplat_pagerduty.*.id,google_monitoring_notification_channel.cloudops_ems_pagerduty.*.id)}"
}

resource "google_monitoring_alert_policy" "alert_policy1" {
  
  display_name = "CloudSQL Alert Policy 1 - pg-db-instance-${var.customer}-${var.env}"
  project      = var.project
  combiner     = "OR"
  conditions {
    display_name = "Memory Utilization"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/memory/utilization\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "0.7"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  conditions {
    display_name = "CPU Utilization"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/cpu/utilization\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "0.7"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }
  conditions {
    display_name = "Disk Utilization"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/disk/utilization\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "0.7"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Per query execution times"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/perquery/execution_time\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "12"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  conditions {
    display_name = "Replica Lag Bytes"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/postgresql/replication/replica_byte_lag\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "50"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Temporary files used for writing data"
    condition_threshold {
      filter          = "metric.type=\"cloudsql.googleapis.com/database/postgresql/temp_files_written_count\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      threshold_value = "10"
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

}

resource "google_monitoring_alert_policy" "alert_policy2" {
  
  display_name = "CloudSQL Alert Policy 2 - pg-db-instance-${var.customer}-${var.env}"
  project      = var.project
  combiner     = "OR"

  conditions {
    display_name = "Auto-failover Requests"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/auto_failover_request_count\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Available for failover"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/available_for_failover\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Bytes used"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/disk/bytes_used\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Bytes used by data type"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/disk/bytes_used_by_data_type\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Database disk quota"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/disk/quota\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Disk read IO"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/disk/read_ops_count\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

}

resource "google_monitoring_alert_policy" "alert_policy3" {
  
  display_name = "CloudSQL Alert Policy 3 - pg-db-instance-${var.customer}-${var.env}"
  project      = var.project
  combiner     = "OR"

  conditions {
    display_name = "Disk write IO"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/disk/write_ops_count\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Memory quota"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/memory/quota\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Total memory usage"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/memory/total_usage\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Deadlock count"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/deadlock_count\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Execution Time"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/aggregate/execution_time\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  conditions {
    display_name = "IO Time"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/aggregate/io_time\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

}

resource "google_monitoring_alert_policy" "alert_policy4" {
  
  display_name = "CloudSQL Alert Policy 4 - pg-db-instance-${var.customer}-${var.env}"
  project      = var.project
  combiner     = "OR"

  #  conditions {
  #    display_name = "Latencies"
  #    condition_threshold {
  #      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/aggregate/latencies\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
  #      duration   = "300s"
  #      comparison = "COMPARISON_GT"
  #      aggregations {
  #        alignment_period   = "300s"
  #        per_series_aligner = "ALIGN_DELTA"
  #      }
  #    }
  #  }

  conditions {
    display_name = "Aggregated Lock Time"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/aggregate/lock_time\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  conditions {
    display_name = "Execution Time"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/perquery/execution_time\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  conditions {
    display_name = "IO Time"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/perquery/io_time\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  #  conditions {
  #    display_name = "Latencies"
  #    condition_threshold {
  #      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/perquery/latencies\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
  #      duration   = "300s"
  #      comparison = "COMPARISON_GT"
  #      aggregations {
  #        alignment_period   = "300s"
  #        per_series_aligner = "ALIGN_DELTA"
  #      }
  #    }
  #  }

  conditions {
    display_name = "Aggregated Lock Time"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/insights/perquery/lock_time\" AND resource.type=\"cloudsql_instance_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

}

resource "google_monitoring_alert_policy" "alert_policy5" {
  
  display_name = "CloudSQL Alert Policy 5 - pg-db-instance-${var.customer}-${var.env}"
  project      = var.project
  combiner     = "OR"

  conditions {
    display_name = "PostgreSQL Connections"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/num_backends\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "PostgreSQL Connections by application"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/num_backends_by_application\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "PostgreSQL Connections by State"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/num_backends_by_state\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Data (in bytes) written to temporary"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/temp_bytes_written_count\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Temporary files used for writing data"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/temp_files_written_count\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Number of transactions"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/transaction_count\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

}

resource "google_monitoring_alert_policy" "alert_policy6" {
  
  display_name = "CloudSQL Alert Policy 6 - pg-db-instance-${var.customer}-${var.env}"
  project      = var.project
  combiner     = "OR"

  conditions {
    display_name = "Transaction ID utilization"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/transaction_id_utilization\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Oldest transaction age"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/postgresql/vacuum/oldest_transaction_age\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Server up"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/up\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

  conditions {
    display_name = "Server uptime"
    condition_threshold {
      filter     = "metric.type=\"cloudsql.googleapis.com/database/uptime\" AND resource.type=\"cloudsql_database\" AND metadata.system_labels.\"name\"=\"pg-db-instance-${var.customer}-${var.env}\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }
    }
  }

}