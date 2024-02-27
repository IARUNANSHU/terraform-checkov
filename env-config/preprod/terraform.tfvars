# Environment details
project     = "terr-basic"
region      = "us-east4"
customer    = "xecm8"
env         = "preprod"
dryrun      = true

# Product deployment details
product         = "xecm"
product_details = "xecm-successfactors"
product_version = "23.1.0"
deployment_size = "small"

# Access Type
# Public Internet or VPN
access_type = "Public Internet"

# Cluster details
cluster_version = "1.24.10-gke.2300"

# Network details
subnetwork        = "otc-backend-ems-vpc-us-east4-cust08"
master_ipv4       = "10.215.178.208/28"
ip_range_services = "gke-services-02"

# trident details
trident_cvo_size = "2-TB"
cvo_required     = false
#trident_version = "22.07.0"

# CVS
cvs_size = 100      # Valid value is 100 and 500 in GB

# Postgres Detail
pg_db_version   = "POSTGRES_15"

## Additional NFS share 
# enable_additional_nfs = false
# additional_nfs_size = 100
# additional_nfs_service_level = "standard"

## CVS size override
# cvs_size_override = true
# cvs_custom_size = 100

# Uncomment and update trident details in case of upgrade
#upgrade_trident = true

# Add details on any addons or customization separated by comma
#customization_details = "French Language Pack"

# additional object storage in Gigabytes
#additional_object_storage = "100"

# Hard core Postgres VM IP address if there is a rebuild
#postgres_ip_address = "x.x.x.x"

####### Custom deployment details ########

## Cluster node pool details
#node_machine_type  = "custom-26-51200"
#gke_num_nodes = "2"

## postgres VM details
#postgres_instance_type = "custom-5-14336"

## postgres application schema size based on the environment
#application_schema_size = "13"

