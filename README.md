### **Terraform creation**

1) Under "https://gitlab.otxlab.net/ems_cloudops/terraform/gcp/customer" create an empty project called "otc-ems-ce-dryrun1-xecm8".

2) Run the below command to clone to your local machine :       
   `git clone https://gitlab.otxlab.net/ems_cloudops/terraform/gcp/dryruns/otc-ems-ce-dryrun1-xecm8.git`
   
3) Update terraform.tfvars file as per the requirement present under preprod/env_vars.

4) Commit changes back to git.

### **Terraform updates (for infra updates and maintenance)**

1) Run the below command on your local machine:          
   `git clone https://gitlab.otxlab.net/ems_cloudops/terraform/gcp/dryruns/otc-ems-ce-dryrun1-xecm8.git`

2) Navigate to "otc-ems-ce-dryrun1-xecm8"

3) Update terraform.tfvars file as per the requirement present under dev/env_vars, prod/env_vars and test/env_vars.

4) Commit changes back to git.

### **Terraform and Ansible execution**

1. Connect to the GCP jumpbox based on the region (gcp-admgke-m01 in this case).
2. Clone git repo for "xecm8" customer onto the jumpbox with the below command:          
   `git clone https://gitlab.otxlab.net/ems_cloudops/terraform/gcp/dryruns/otc-ems-ce-dryrun1-xecm8.git`
3. Navigate inside "otc-ems-ce-dryrun1-xecm8" and run the below make commands to deploy the infrastructure through terraform.

##### Prod environment

   Run the below command to deploy GKE infrastructure (including GKE cluster and VMs) through terraform and then ingress, CVO, trident, Prometheus, DNS & CNAME, Sectigo certificates and Velero through Ansible roles.       
   `make master_deploy CUSTOMER=xecm8 ENV=preprod`

   For monitoring (Prometheus and Zabbix) disable run the below command.         
   `make monitoring_disable CUSTOMER=xecm8 ENV=preprod`

**Note:**
1. master_vars and pg_vars files created under env_vars can be used for running the ansible roles for installing/updating cluster components and postgres database server. This is pushed to git as part of "master_deploy" command.
2. Operations team will need to enable monitoring at the time of customer go live with the below command:      
   `make monitoring_enable CUSTOMER=xecm8 ENV=preprod`
2. To run the above all the above commands, below are the pre-requisites:     
   a) tfenv should be installed on the jumpbox by following https://github.com/tfutils/tfenv.      
   b) zabbix-api need to be installed through "python3 -m pip install zabbix-api" command.      
   c) terraform_key.json file should exist outside the git repo directory on the jumpbox. This has to be downloaded from GCP with the below command.        
      `gcloud secrets versions access latest --secret=otc-ems-terraform-prod --project=otc-ems-services > terraform_key.json`