locals {
  infra_specs_db_schema_csd25 = {
    spare = {
      small = {
        application_schema_size = "100"
      }
      custom = {
        application_schema_size = var.application_schema_size
      }
    },
    preprod = {
      small = {
        application_schema_size = "100"
      }
      custom = {
        application_schema_size = var.application_schema_size
      }
    },
    dev = {
      small = {
        application_schema_size = "100"
      }
      custom = {
        application_schema_size = var.application_schema_size
      }
    },
    test = {
      small = {
        application_schema_size = "100"
      }
      custom = {
        application_schema_size = var.application_schema_size
      }
    },
    prod = {
      small1 = {
        application_schema_size = "100"
      }
      small2 = {
        application_schema_size = "100"
      }
      small3 = {
        application_schema_size = "100"
      }
      small-medium1 = {
        application_schema_size = "100"
      }
      small-medium2 = {
        application_schema_size = "123"
      }
      small-medium3 = {
        application_schema_size = "184"
      }
      medium1 = {
        application_schema_size = "184"
      }
      medium2 = {
        application_schema_size = "240"
      }
      medium3 = {
        application_schema_size = "360"
      }
      medium-large1 = {
        application_schema_size = "360"
      }
      medium-large2 = {
        application_schema_size = "587"
      }
      medium-large3 = {
        application_schema_size = "822"
      }
      large1 = {
        application_schema_size = "822"
      }
      large2 = {
        application_schema_size= "1149"
      }
      large3 = {
        application_schema_size = "1724"
      }
      extra-large1 = {
        application_schema_size = "1724"
      }
      extra-large2 = {
        application_schema_size = "2200"
      }
      extra-large3 = {
        application_schema_size = "3741"
      }
      xx-large1 = {
        application_schema_size = "3741"
      }
      xx-large2 = {
        application_schema_size = "10999"
      }
      custom = {
        application_schema_size = var.application_schema_size
      }
    }
  }
}

locals {
  infra_specs_total_db_schema = {
    application_schema_size_total = floor(local.infra_specs_db_schema_csd25[var.env][var.deployment_size].application_schema_size + (var.additional_object_storage * 0.2))
  }
}

locals {
  infra_specs = {
    spare = {
      small = {
        # gke cluster details
        node_machine_type = "custom-26-51200"
        gke_num_nodes = "2"

        # Postgres Database server details
        postgres_instance_type = "db-custom-6-14336"
      }

      custom = {
        # gke cluster details
        node_machine_type = var.node_machine_type
        gke_num_nodes = var.gke_num_nodes

        # Postgres Database server details
        postgres_instance_type = var.postgres_instance_type
      }
    },

    dev = {
      small = {
        # gke cluster details
        node_machine_type = "custom-26-51200"
        gke_num_nodes = "2"

        # Postgres Database server details
        postgres_instance_type = "db-custom-6-14336"
      }

      custom = {
        # gke cluster details
        node_machine_type = var.node_machine_type
        gke_num_nodes = var.gke_num_nodes

        # Postgres Database server details
        postgres_instance_type = var.postgres_instance_type
      }
    },

    test = {
      small = {
        # gke cluster details
        node_machine_type = "custom-26-51200"
        gke_num_nodes = "2"

        # Postgres Database server details
        postgres_instance_type = "db-custom-6-14336"
      }

      custom = {
        # gke cluster details
        node_machine_type = var.node_machine_type
        gke_num_nodes = var.gke_num_nodes

        # Postgres Database server details
        postgres_instance_type = var.postgres_instance_type
      }
    },

    prod = {
      small1 = {
        # gke cluster details
        node_machine_type = "custom-20-40960"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-6-16384"
      }

      small2 = {
        # gke cluster details
        node_machine_type = "custom-20-40960"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-6-16384"
      }

      small3 = {
        # gke cluster details
        node_machine_type = "custom-20-40960"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-6-16384"
      }

      small-medium1 = {
        # gke cluster details
        node_machine_type = "custom-26-53248"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-8-24576"
      }

      small-medium2 = {
        # gke cluster details
        node_machine_type = "custom-26-53248"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-8-24576"
      }

      small-medium3 = {
        # gke cluster details
        node_machine_type = "custom-26-53248"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-8-24576"
      }

      medium1 = {
        # gke cluster details
        node_machine_type = "custom-30-67584"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-10-43008"
      }

      medium2 = {
        # gke cluster details
        node_machine_type = "custom-30-67584"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-10-43008"
      }

      medium3 = {
        # gke cluster details
        node_machine_type = "custom-30-67584"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-10-43008"
      }

      medium-large1 = {
        # gke cluster details
        node_machine_type = "custom-40-92160"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-18-64512"
      }

      medium-large2 = {
        # gke cluster details
        node_machine_type = "custom-46-104448"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-18-64512"
      }

      medium-large3 = {
        # gke cluster details
        node_machine_type = "custom-40-92160"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-18-64512"
      }

      large1 = {
        # gke cluster details
        node_machine_type = "custom-54-124928"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-24-86016"
      }

      large2 = {
        # gke cluster details
        node_machine_type = "custom-54-124928"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-24-86016"
      }

      large3 = {
        # gke cluster details
        node_machine_type = "custom-54-124928"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-24-86016"
      }

      extra-large1 = {
        # gke cluster details
        node_machine_type = "custom-78-176128"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-24-125952"
      }

      extra-large2 = {
        # gke cluster details
        node_machine_type = "custom-78-176128"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-24-125952"
      }

      extra-large3 = {
        # gke cluster details
        node_machine_type = "custom-78-176128"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-24-125952"
      }

      xx-large1 = {
        # gke cluster details
        node_machine_type = "custom-254-634880"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-60-247808"
      }

      xx-large2 = {
        # gke cluster details
        node_machine_type = "custom-254-634880"
        gke_num_nodes = "1"

        # Postgres Database server details
        postgres_instance_type = "db-custom-60-247808"
      }

      custom = {
        # gke cluster details
        node_machine_type = var.node_machine_type
        gke_num_nodes = var.gke_num_nodes

        # Postgres Database server details
        postgres_instance_type = var.postgres_instance_type
      }
    },

    preprod = {
      small = {
        # gke cluster details
        node_machine_type = "custom-26-51200"
        gke_num_nodes = "2"

        # Postgres Database server details
        postgres_instance_type = "db-custom-6-14336"
      }

      custom = {
        # gke cluster details
        node_machine_type = var.node_machine_type
        gke_num_nodes = var.gke_num_nodes

        # Postgres Database server details
        postgres_instance_type = var.postgres_instance_type
      }
    }
  }
}
