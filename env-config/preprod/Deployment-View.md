#### Deployment Title
**xecm-successfactors** **23.1.0** deployment for **xecm8** customer in the **GCP** **preprod** environment.


#### Customer Environment Details

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Customer            | Four character short name for the customer| xecm8 |
   | Environment         | Environment (dev/test/preprod/prod)       | preprod      |
   | Platform            | Platform on which the customer environment is deployed | GCP  |
   | Project             | GCP project name                          | otc-ems-ce-dryrun1  |  
   | Region              | GCP deployment region                     | us-east4   |


#### Product Details

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Product             | Short name of the product                 | xecm-successfactors  |
   | Product version     | CE release version of the product         | 23.1.0 |
   | CSD 11 link         | Ollie link to the build book              | https://intranet.opentext.com/intranet/llisapi.dll/app/nodes/220579764           |
   | Deployment size     | Product deployment size (refer CSD-25)    | small |
   | Addon Components/Customizations | Details on any kind of customization on top of the standard CE build  | null |


#### Infrastructure Details

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Cluster Name        | GKE Cluster Name                          | otc-ems-ce-dryrun1-xecm8  |
   | Cluster Connection  | gcloud command to connect to the GKE cluster | gcloud container clusters get-credentials otc-ems-ce-dryrun1-xecm8 --zone us-east4-a --project otc-ems-ce-dryrun1 |
   | Application Namespace| Application Namespace in GKE cluster      | xecm8-preprod |
   | Access Type| Whether Application can be accessed on Public Internet or VPN    | Public Internet |
   | Deployment RHEL Jumpbox | GCP deployment RHEL jumpbox based on the region | gcp-admgke-m02.cloud.opentext.com |
   | Deployment Windows Jumpbox | GCP deployment Windows jumpbox based on the region | gcp-admin-m02.cloud.opentext.com |
   | Subnetwork          | GCP subnet                                | otc-backend-ems-vpc-us-east4-cust08          |
   | Postgres Server Host Name     | Postgres Server Host Name in GCP         | [[{"ip_address":"10.212.65.30","time_to_retire":"","type":"PRIVATE"}]] |
   | Velero Version      | Velero version deployed on cluster        | v1.8.1 |
   | Kube-Prometheus Version | Kube-prometheus stack version deployed on cluster | v0.50.0 |
   | Ingress Nginx version | Ingress Nginx version deployed on cluster       | v1.4.0 |
   | Trident Version       | NetApp trident version deployed on cluster | NA |
   | CVS Name            | Google Cloud Volume Service Name          | xecm8-preprod-cvs            |
   | CVS IP address      | IP address of CVS volume                  | 10.183.64.4       |
   | CVS Size            | Size of CVS storage                       | 100 Gi         |
   | CSI Driver Version  | Version of CSI driver for NFS/CVS         | v4.2.0 |


#### Application URLs

   | Name               | Description                                          | Value                  |
   |------------------------------------------------------| ------------------------------------------| -----------------------|
   | OTCS URL | OT Content Server URL                                | https://otcs.xecm8-preprod.opentext.cloud/cs/cs |
   | OTDS URL | OT Directory Service URL                             | https://otds.xecm8-preprod.opentext.cloud/otds-admin |
   | OTAC URL | OT Archive Center URL                                | https://otac.xecm8-preprod.opentext.cloud/archive?admInfo&pVersion=0046&resultAs=html |
   | OTAG URL | OT AppWorks Gateway URL                              | https://otag.xecm8-preprod.opentext.cloud/ |
   | OTIV URL | OT Asset Service URL                                 | https://otiv-asset.xecm8-preprod.opentext.cloud/asset/api/v1/version |
   | OTIV URL | OT Highlight Service URL                             | https://otiv-highlight.xecm8-preprod.opentext.cloud/search/api/v1/version |
   | OTIV URL | OT Markup Service URL                                | https://otiv-markup.xecm8-preprod.opentext.cloud/markup/api/v1/version |
   | OTIV URL | OT Publication Service URL                           | https://otiv-publication.xecm8-preprod.opentext.cloud/publication/api/v1/version |
   | OTIV URL | OT Viewer Service URL                                | https://otiv-viewer.xecm8-preprod.opentext.cloud/viewer/api/v1/version |
   | OTPD URL | OT Content Manager URL                               | https://pdocs.xecm8-preprod.opentext.cloud/ContentManager/ |
   | OTPD URL | OT Server Manager URL                                | https://pdocs.xecm8-preprod.opentext.cloud/ServerManager/ |
   | OTPD URL | OT c4ApplicationServer URL                           | https://pdocs.xecm8-preprod.opentext.cloud/c4ApplicationServer/ |
   | OTPD URL | OT c4DocumentServer URL                              | https://pdocs.xecm8-preprod.opentext.cloud/c4DocumentServer/ |
   | OTPD URL | OT c4EnterpriseConversionServer URL                  | https://pdocs.xecm8-preprod.opentext.cloud/c4EnterpriseConversionServer/ |
   | OTPD URL | OT c4OutputServer URL                                | https://pdocs.xecm8-preprod.opentext.cloud/c4OutputServer/ |
   | OOB Monitoring URL | OOB URL which can be used for health check monitoring | https://xecm8-preprod.wopi.opentext.cloud/wopi/status                                 |
   | OOB Integration URL | OOB URL which can be used to integrate with OTCS     | https://xecm8-preprod.wopi.opentext.cloud/wopi                                        |

#### Cloud Logging URL

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Google Cloud Logging URL | Google Cloud Logging URL for the containers in the application name | https://console.cloud.google.com/logs/query;query=resource.labels.cluster_name%3D%22otc-ems-ce-dryrun1-xecm8%22%0Aresource.labels.location%3D%22us-east4-a%22%0Aresource.labels.namespace_name%3D%22xecm8-preprod%22?project=otc-ems-ce-dryrun1 |


#### Prometheus Monitoring URLs

   | Name                | Description                               | Value                  |
   | ------------------- | ------------------------------------------| -----------------------|
   | Prometheus URL | Web URL for Prometheus (accessible from gcp-admin-m02.cloud.opentext.com only) | http://prometheus-xecm8-preprod.cust.cloud.opentext.com |
   | Grafana URL | Web URL for Grafana (accessible from gcp-admin-m02.cloud.opentext.com only) | http://grafana-xecm8-preprod.cust.cloud.opentext.com |
   | Alert Manager URL | Web URL for Alert Manager (accessible from gcp-admin-m02.cloud.opentext.com only) | http://alertmanager-xecm8-preprod.cust.cloud.opentext.com |

