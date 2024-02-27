variable "region" {
  description = "Default region for deploying resources"
}

variable "project" {
  description = "The project to use when deploying resources"
}

#variable "cluster_name" {
#  description = "cluster name"
#}

variable "cluster_version" {
  description = "cluster version"
}

#variable "regional_cluster" {
#  description = "Deploy the cluster with redundancy"
#}

variable "network_project_id" {
  description = "Host Project for Shared VPC network"
  default     = "terr-basic"
}

variable "network" {
  description = "VPC Network for Nodes"
  default     = "default"
}

variable "ip_range_pods" {
  description = "Secondary IP Range for Pods"
  default     = "gke-pods"
}

variable "ip_range_services" {
  description = "Secondary IP Range for Services"
}

variable "http_lb" {
  description = "Use the Google HTTP Load Balancer function"
  default     = "true"
}

variable "ip_masq" {
  description = "Configure the cluster to use IP Masquerading"
  default     = "true"
}

variable "non_masq_cidrs" {
  description = "List of CIDR ranges for which IP Masquerading should not occur"
  default     = ["172.30.160.0/24", "192.168.160.0/24"]
}

variable "horizontal_autoscaling" {
  description = "Configure the cluster to use Horizontal Pod Autoscaling"
  default     = "false"
}



variable "master_ipv4" {
  description = "IPv4 Definition of the network to be used by Master Nodes"
}

variable "master_authorized_networks" {
  description = "List of networks that are allowed to access the Master Nodes"
  default     = [{ display_name = "OT_Corp", cidr_block = "10.0.0.0/8" }]
}

variable "create_sa" {
  description = "Create service account for nodes to use"
  default     = "true"
}

#variable "nameservers" {
#  description = "List of nameservers to use in lieu of pre-defined"
#}

variable "enable_private_endpoint" {
  description = "Whether the master's internal IP address is used as the cluster endpoint"
  default     = "true"
}

variable "enable_private_nodes" {
  description = "Whether nodes have internal IP addresses only"
  default     = "true"
}

variable "remove_default_node_pool" {
  description = "Remove default node pool while setting up the cluster"
  default     = "true"
}

variable "skip_provisioners" {
  description = "Skip post-deploy provisioning"
  default     = "true"
}

variable "deploy_using_private_endpoint" {
  description = "A toggle for Terraform and kubectl to connect to the master's internal IP address during deployment"
  default     = "true"
}

variable "disk_size" {
  description = "Disk size in GB for worker nodes"
  default     = "100"
}

#variable "disk_type" {
#  description = "Disk type for node disks - pd-standard or pd-ssd"
#}
variable "network_policy" {
  description = "Enable Network Policy feature on the cluster"
  default = "true"
}
variable "enable_binary_authorization" {
  description = "Ensure only authorized build images are deployed on GKE"
  default = "true"
}

variable "image_type" {
  description = "Node OS image"
  default     = "COS"
}

variable "auto_repair" {
  description = "Enable node auto-repair"
  default     = "true"
}

variable "auto_upgrade" {
  description = "Enable node auto-upgrade"
  default     = "true"
}

variable "autoscaling" {
  description = "Enable node pool autoscaling"
  default     = "false"
}

variable "preemptible" {
  description = "Use preemptible node type"
  default     = "false"
}

#variable "externalip_name" {
#  description = "hostname for the external IP"
#}

#variable "externalip_description" {
#  description = "FQDN for the external IP"
#}

variable "customer" {
  description = "customer shortname"
}

variable "env" {
  description = "Environment test,dev,prod etc"
}

variable "startup_script" {
  type = map(any)
  default = {
    win = "gs://otc-ems-services/win_startup_script.ps1"
    lnx = "gs://otc-ems-services/startup_otc.sh"
  }
}

variable "emsproject" {
  description = "used to declare the ems project, usually otc-ems-services"
  default     = "otc-ems-services"
}

#variable "network_tags" {
#  description = "network tags for the Kubernetes cluster"
#}

variable "uniform_bucket_level_access" {
  default = "true"
}
variable "storage_class" {
  default = "standard"
}

variable "env_shortcodes" {
  type = map(string)
  default = {
    "dev"  = "d"
    "test" = "t"
    "prod" = "p"
    "preprod" = "s"

  }
}

variable "cvo_required" {
  type = bool
  default = false
}


variable "trident_cvo_size" {}
variable "trident_version" {
  description = "Trident version"
  default     = "22.07.0"
}

variable "upgrade_trident" {
  type = bool
  default = false
}

variable "dns_type" {
  description = "DNS type. Possible values : oob-non-wildcard, non-wildcard, wildcard"
  default     = "wildcard"
}
variable "cert_type" {
  description = "Certificate type. Possible values : oob-non-wildcard, non-wildcard, wildcard"
  default     = "wildcard"
}
variable "san_required" {
  description = "This flag decides if SAN (Subject Alternate Name) is needed or not"
  default     = "false"
}

variable "san_dns" {
  description = "if san_required is set to true then set the SAN value"
  default     = ""
}

variable "dryrun" {
  description = "This flag decides if it is a dryrun environemnt or not"
}

variable "product" {
  description = "Name of the product to be deployed on this environment"
}

variable "product_details" {
  description = "Name of the exact solution to be deployed under the given product family"
}

variable "product_version" {
  description = "Version of the product to be deployed on this environment"
}

variable "deployment_size" {
  description = "Product deployment size"
}

variable "deployment_tier" {
  description = "Product deployment tier. Possible values : standard, enhanced"
  default     = "standard"
}

variable "gke_network_tags" {
  type    = list(string)
  default = []
}

variable "release_channel" {
  description = "The GKE Release Channel"
  type        = string
  default     = "UNSPECIFIED"
}

variable "pg_db_disk_size" {
  default = ""
}

variable "pg_db_tier" {
  default = ""
}

variable "pg_db_version" {
  default = ""
}

variable "o365_machine_type" {
  default = ""
}
#variable "o365_ip_address" {}
variable "o365_attached_disk_size" {
  default = "100"
}

variable "node_machine_type" {
  description = "Machine type for nodes"
  default = ""
}

variable "subnetwork" {
  description = "VPC Subnetwork for Nodes"
}

variable "pg_disk1" {
  default = "0"
}

variable "pg_disk2" {
  default = "0"
}

variable "pg_disk3" {
  default = "0"
}

variable gke_num_nodes {
  default = "0"
}

variable "postgres_instance_type" {
  default = ""
}

variable "postgres_attached_disk_size" {
  default = "0"
}

variable "additional_object_storage" {
  default = "0"
}

variable "application_schema_size" {
  default = "0"
}

variable "lab_vm_required" {
  default = false
}

variable "lab_instance_type" {
  default = ""
}

variable "lab_attached_disk1_size" {
  default = "0"
}

variable "lab_attached_disk2_size" {
  default = "0"
}

variable "lab_attached_disk3_size" {
  default = "0"
}

variable "customization_details" {
  default = "null"
}

variable "csd11_link" {
  type = map(string)
  default = {
    "22.2.0" = "https://intranet.opentext.com/intranet/llisapi.dll/app/nodes/213512999"
    "22.2.1" = "https://intranet.opentext.com/intranet/llisapi.dll/app/nodes/213512999"
    "22.2.2" = "https://intranet.opentext.com/intranet/llisapi.dll/app/nodes/213512999"
    "22.3.0" = "https://intranet.opentext.com/intranet/llisapi.dll/app/nodes/215960533"
    "22.4.7" = "https://intranet.opentext.com/intranet/llisapi.dll/app/nodes/218077486"
    "23.1.0" = "https://intranet.opentext.com/intranet/llisapi.dll/app/nodes/220579764"
  }
}

variable "deployment_rhel_jumpbox" {
  type = map(string)
  default = {
    "us-east4" = "gcp-admgke-m02.cloud.opentext.com"
    "europe-west3" = "gcp-admgke-m03.cloud.opentext.com"
    "asia-northeast1" = "gcp-admgke-m04.cloud.opentext.com"
    "northamerica-northeast1" = "gcp-admgke-m05.cloud.opentext.com"
    "australia-southeast1" = "gcp-admgke-m06.cloud.opentext.com"
    "southamerica-east1" = "gcp-admgke-m07.cloud.opentext.com"
    "europe-west2" = "gcp-admgke-m08.cloud.opentext.com"
    "asia-southeast2" = "gcp-admgke-m09.cloud.opentext.com"
    "asia-southeast1" = "gcp-admgke-m10.cloud.opentext.com"
  }
}

variable "deployment_windows_jumpbox" {
  type = map(string)
  default = {
    "us-east4" = "gcp-admin-m02.cloud.opentext.com"
    "asia-southeast2" = "gcp-admin-m03.cloud.opentext.com"
    "asia-southeast1" = "gcp-admin-m04.cloud.opentext.com"
    "europe-west3" = "gcp-admin-m05.cloud.opentext.com"
    "asia-northeast1" = "gcp-admin-m06.cloud.opentext.com"
    "northamerica-northeast1" = "gcp-admin-m07.cloud.opentext.com"
    "australia-southeast1" = "gcp-admin-m08.cloud.opentext.com"
    "southamerica-east1" = "gcp-admin-m09.cloud.opentext.com"
    "europe-west2" = "gcp-admin-m10.cloud.opentext.com"
  }
}

variable "access_type" {
  type = string
}

variable "dns_zone" {
  type        = string
  description = "DNS zone/domain"
  default     = "cust.cloud.opentext.com"
}

variable "velero_version" {
  default = "v1.8.1"
}

variable "ingress_nginx_version" {
  default = "v1.4.0"
}

variable "kube_prometheus_version" {
  default = "v0.50.0"
}

variable "service_account" {
 description = "Service account to create CVS"
 default = "otc-ems-terraform-prod@otc-ems-services.iam.gserviceaccount.com"
}

variable "shared_vpc_project" {
  description = "Project id of shared VPC"
  default = "terr-basic"

}

variable "cvs_size" {
  type = string
  description = "Size of CVS out of 100 and 500 GB"
  validation {
    condition = contains(["100", "500"], var.cvs_size)
    error_message = "CVS size must be one of 100 or 500."
  }
}

variable "cvs_service_level" {
  description = "CVS service level. Out of standard, premium and extreme"
  default = "standard"
}

variable "csi_driver_nfs_version" {
    description = "Version of CSI Driver for NFS"
    default = "v4.2.0"
}

variable "monitoring_enable_managed_prometheus" {
  type        = bool
  description = "Configuration for Managed Service for Prometheus. Whether or not the managed collection is enabled."
  default     = true
}

variable "enable_additional_nfs" {
  type = bool
  default = false
  description = "Make it true to create an addtional CVS NFS volume"
}

variable "additional_nfs_size" {
  default = 100
  description = "Size of additional CVS NFS in Gi"
}

variable "additional_nfs_service_level" {
  default = "standard"
  description = "Service level of additional cvs for NFS share. Out of standard, premium and extreme"
}

variable "sftp_machines_zone_a_ip" {
  type = map(string)
  default = {
    "us-east4" = "10.212.8.68"
    "asia-southeast2" = "NA"
    "asia-southeast1" = "10.214.248.7"
    "europe-west3" = "10.212.248.18"
    "asia-northeast1" = "10.212.152.50"
    "northamerica-northeast1" = "10.212.204.2"
    "australia-southeast1" = "10.212.232.13"
    "southamerica-east1" = "10.212.216.3"
    "europe-west2" = "10.212.128.9"
  }
}

variable "sftp_machines_zone_b_ip" {
  type = map(string)
  default = {
    "us-east4" = "NA"
    "asia-southeast2" = "NA"
    "asia-southeast1" = "NA"
    "europe-west3" = "10.212.248.21"
    "asia-northeast1" = "10.212.152.51"
    "northamerica-northeast1" = "10.212.204.3"
    "australia-southeast1" = "10.212.232.14"
    "southamerica-east1" = "10.212.216.4"
    "europe-west2" = "10.212.128.10"
  }
}

variable "cvs_available" {
  type = map(bool)
  default = {
    "us-east4" = true
    "asia-southeast2" = false
    "asia-southeast1" = true
    "europe-west3" = true
    "asia-northeast1" = true
    "northamerica-northeast1" = true
    "australia-southeast1" = true
    "southamerica-east1" = false
    "europe-west2" = true
    "us-west4" = true
    "me-central1" = false
  }
}

# variable "cvs_size_override" {
#   type = bool
#   default = false
#   description = "Used in manual re-sizing of CVS."
# }

# variable "cvs_custom_size" {
#   default = 100
#   description = "Used in manual re-size of CVS volume"
# }

# variable "build_cvs" {
#   type = bool
#   default = false
# }