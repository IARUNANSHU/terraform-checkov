#### Deployment Title
**${local_file_product}** **${local_file_product_version}** deployment for **${local_file_customer}** customer in the **GCP** **${local_file_env}** environment.


#### Customer Environment Details

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Customer            | Four character short name for the customer| ${local_file_customer} |
   | Environment         | Environment (dev/test/preprod/prod)       | ${local_file_env}      |
   | Platform            | Platform on which the customer environment is deployed | GCP  |
   | Project             | GCP project name                          | ${local_file_project}  |  
   | Region              | GCP deployment region                     | ${local_file_region}   |


#### Product Details

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Product             | Short name of the product                 | ${local_file_product}  |
   | Product version     | CE release version of the product         | ${local_file_product_version} |
   | CSD 11 link         | Ollie link to the build book              | ${local_csd11_link}           |
   | Deployment size     | Product deployment size (refer CSD-25)    | ${local_file_deployment_size} |
   | Addon Components/Customizations | Details on any kind of customization on top of the standard CE build  | ${local_customization} |


#### Infrastructure Details

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Cluster Name        | GKE Cluster Name                          | ${local_cluster_name}  |
   | Cluster Connection  | gcloud command to connect to the GKE cluster | ${local_gcloud_command} |
   | Application Namespace| Application Namespace in GKE cluster      | ${local_namespace_name} |
   | Access Type| Whether Application can be accessed on Public Internet or VPN    | ${local_access_type} |
   | Deployment RHEL Jumpbox | GCP deployment RHEL jumpbox based on the region | ${local_deployment_rhel_jumpbox} |
   | Deployment Windows Jumpbox | GCP deployment Windows jumpbox based on the region | ${local_deployment_windows_jumpbox} |
   | Subnetwork          | GCP subnet                                | ${subnetwork}          |
   | Postgres Server Host Name     | Postgres Server Host Name in GCP         | ${local_postgres_server} |
   | Velero Version      | Velero version deployed on cluster        | ${local_velero_version} |
   | Kube-Prometheus Version | Kube-prometheus stack version deployed on cluster | ${local_kube_prometheus_version} |
   | Ingress Nginx version | Ingress Nginx version deployed on cluster       | ${local_ingress_nginx_version} |
   | Trident Version       | NetApp trident version deployed on cluster | ${local_trident_version} |
   | CVS Name            | Google Cloud Volume Service Name          | ${cvs_name}            |
   | CVS IP address      | IP address of CVS volume                  | ${cvs_server_ip}       |
   | CVS Size            | Size of CVS storage                       | ${cvs_vol_size} Gi         |
   | CSI Driver Version  | Version of CSI driver for NFS/CVS         | ${csi_driver_nfs_version} |


#### Application URLs

   | Name               | Description                                          | Value                  |
   |------------------------------------------------------| ------------------------------------------| -----------------------|
   | OTCS URL | OT Content Server URL                                | https://otcs.${app_dns}.opentext.cloud/cs/cs |
   | OTDS URL | OT Directory Service URL                             | https://otds.${app_dns}.opentext.cloud/otds-admin |
   | OTAC URL | OT Archive Center URL                                | https://otac.${app_dns}.opentext.cloud/archive?admInfo&pVersion=0046&resultAs=html |
   | OTAG URL | OT AppWorks Gateway URL                              | https://otag.${app_dns}.opentext.cloud/ |
   | OTIV URL | OT Asset Service URL                                 | https://otiv-asset.${app_dns}.opentext.cloud/asset/api/v1/version |
   | OTIV URL | OT Highlight Service URL                             | https://otiv-highlight.${app_dns}.opentext.cloud/search/api/v1/version |
   | OTIV URL | OT Markup Service URL                                | https://otiv-markup.${app_dns}.opentext.cloud/markup/api/v1/version |
   | OTIV URL | OT Publication Service URL                           | https://otiv-publication.${app_dns}.opentext.cloud/publication/api/v1/version |
   | OTIV URL | OT Viewer Service URL                                | https://otiv-viewer.${app_dns}.opentext.cloud/viewer/api/v1/version |
   | OTPD URL | OT Content Manager URL                               | https://pdocs.${app_dns}.opentext.cloud/ContentManager/ |
   | OTPD URL | OT Server Manager URL                                | https://pdocs.${app_dns}.opentext.cloud/ServerManager/ |
   | OTPD URL | OT c4ApplicationServer URL                           | https://pdocs.${app_dns}.opentext.cloud/c4ApplicationServer/ |
   | OTPD URL | OT c4DocumentServer URL                              | https://pdocs.${app_dns}.opentext.cloud/c4DocumentServer/ |
   | OTPD URL | OT c4EnterpriseConversionServer URL                  | https://pdocs.${app_dns}.opentext.cloud/c4EnterpriseConversionServer/ |
   | OTPD URL | OT c4OutputServer URL                                | https://pdocs.${app_dns}.opentext.cloud/c4OutputServer/ |
   | OOB Monitoring URL | OOB URL which can be used for health check monitoring | https://${app_dns}.wopi.opentext.cloud/wopi/status                                 |
   | OOB Integration URL | OOB URL which can be used to integrate with OTCS     | https://${app_dns}.wopi.opentext.cloud/wopi                                        |

#### Cloud Logging URL

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Google Cloud Logging URL | Google Cloud Logging URL for the containers in the application name | https://console.cloud.google.com/logs/query;query=resource.labels.cluster_name%3D%22${local_cluster_name}%22%0Aresource.labels.location%3D%22${local_location}%22%0Aresource.labels.namespace_name%3D%22${local_namespace_name}%22?project=${local_file_project} |


#### Prometheus Monitoring URLs

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Prometheus URL | Web URL for Prometheus (accessible from ${local_deployment_windows_jumpbox} only) | http://prometheus-${local_file_customer}-${local_file_env}.cust.cloud.opentext.com |
   | Grafana URL | Web URL for Grafana (accessible from ${local_deployment_windows_jumpbox} only) | http://grafana-${local_file_customer}-${local_file_env}.cust.cloud.opentext.com |
   | Alert Manager URL | Web URL for Alert Manager (accessible from ${local_deployment_windows_jumpbox} only) | http://alertmanager-${local_file_customer}-${local_file_env}.cust.cloud.opentext.com |

