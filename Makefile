# $ make target CUSTOMER=customer_short_name ENV=customer_environment
# E.g $ make deploy CUSTOMER=abcd ENV=test

########################################################################################################################################################
# Pre-defined variables

PROXY = http://proxy-gcp.cloud.opentext.com:3128
TFWORKSPACE = $(CUSTOMER)-$(ENV)
TFVERSION = 1.3.6

########################################################################################################################################################
# Make targets to execute for deployment

# 1. Deployment pre-requisites setup
deploy_pre_req: pre-req-ansible

# 2. GCP project creation. Do not run for dry run.
gcp_project_setup: gcp-project-setup

# 3. Pre-req Jira to network, DNS and GCP billing team
pre_req_jiras: pre-req-jiras

# 4. Master deployment target including both terraform and ansible execution. To be run ONLY after pre-req Jiras are complete for network and DNS.
master_deploy: pre-req-ansible tf_deploy ansible_deploy

# 5. Postgres Deployment
postgres_deploy: postgres

# 6. Zabbix Monitoring check
monitoring_check: zabbix_check

########################################################################################################################################################
# Zabbix and Prometheus Monitoring Disable/Enable if needed

# Disable Monitors
monitoring_disable: zabbix_disable prometheus_silence_add

# Enable Monitors - To be run by Cloud Ops Platform Operations team if the monitoring was disabled during provisioning
monitoring_enable: zabbix_enable prometheus_silence_remove

########################################################################################################################################################
# Consolidated targets
tf_deploy: tf_init tf_apply git_push
ansible_deploy: pre-req-ansible ingress cvo trident prometheus sectigo velero nr_cert_monitoring

# CSI Driver for NFS for CVS
cvs: cvs_nfs_driver
cvs_driver: cvs_nfs_driver

########################################################################################################################################################
# Pre-requisites

pre-req-ansible:
	cd infra-templates/ansible/playbooks && \
	rm -rf roles && \
	mkdir roles && \
    cd roles && \
    git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/gcp-project-setup.git && \
    git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/gkejiras.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/ingress-nginx.git && \
	cd ingress-nginx && \
	git checkout feature/upgrade_nginx_to_1.4.0 && \
	cd .. && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/createtridentcvo.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/trident.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/cvs-nfs-driver.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/prometheus.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/sectigo.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/universal_velero_install.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/zabbix_monitoring.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/prometheus_add_remove_silence.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/nr_cert_monitoring.git && \
	git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/gcp-managed-prometheus.git && \
	cd .. && \
    rm -rf postgres_playbook && \
    git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/postgres_playbook.git && \
    cd postgres_playbook/playbooks && \
    #git clone https://gitlab.otxlab.net/ems-dba-team/postgres.cluster.rhel.git && \
    git clone https://gitlab.otxlab.net/ems_cloudops/ansible/roles/ansible-manage-lvm.git

########################################################################################################################################################

# GCP project creation with default billing ID
gcp-project-setup:
	cd infra-templates/ansible/playbooks/roles && \
    ansible-playbook gcp-project-setup/playbook.yml -e customer="$(CUSTOMER)" && \
    cd $(HOME)/gcp-projects && \
    export http_proxy=$(PROXY) && export https_proxy=$(PROXY) && \
    tfenv install $(TFVERSION) && tfenv use $(TFVERSION) && \
    rm -rf .terraform && \
    cp $(HOME)/terraform_key.json . && \
    terraform init -backend-config="credentials=terraform_key.json" && \
	cd $(HOME)/gcp-projects && \
	unset http_proxy && unset https_proxy && \
    terraform workspace select $(CUSTOMER) || terraform workspace new $(CUSTOMER) && \
	terraform apply -var-file="customers/$(CUSTOMER)/$(CUSTOMER)_prod.tfvars"

########################################################################################################################################################
# Jira creation

# Jira to network team (CSDCNCLOUD) to attach network to GCP project
attach-network:
	cd infra-templates/ansible/playbooks/roles && \
    ansible-playbook gkejiras/playbook.yml -e customer="$(CUSTOMER)" -e environment="$(ENV)" -e JiraType="attachnetwork" -e subnet_name=$(GCP_SUBNET_NAME)

# Jira to DNS team (CSDDS) to attach DNS zone to GCP project
attach-domain:
	cd infra-templates/ansible/playbooks/roles && \
    ansible-playbook gkejiras/playbook.yml -e customer="$(CUSTOMER)" -e JiraType="dns"

# Master target which covers the above three Jira creation
pre-req-jiras:
	cd infra-templates/ansible/playbooks/roles && \
    ansible-playbook gkejiras/playbook.yml -e customer="$(CUSTOMER)" -e JiraType="pre-req" -e subnet_name=$(GCP_SUBNET_NAME)

########################################################################################################################################################
# Terraform execution

# Terraform Init
tf_init:
	export GOOGLE_APPLICATION_CREDENTIALS=$(HOME)/terraform_key.json && \
	export http_proxy=$(PROXY) && export https_proxy=$(PROXY) && \
	tfenv install $(TFVERSION) && tfenv use $(TFVERSION) && \
	cd infra-templates/terraform/config && \
	rm -rf .terraform && \
	terraform init -backend-config="bucket=otc-ems-tf-state" -backend-config="prefix=$(CUSTOMER)-$(ENV)" && \
	unset http_proxy && unset https_proxy

# Terraform Plan
tf_plan:
	export GOOGLE_APPLICATION_CREDENTIALS=$(HOME)/terraform_key.json && \
	cd infra-templates/terraform/config && \
	tfenv use $(TFVERSION) && \
	unset http_proxy && unset https_proxy && \
	terraform workspace select $(TFWORKSPACE) || terraform workspace new $(TFWORKSPACE) && \
	terraform plan -var-file="../../../env-config/$(ENV)/terraform.tfvars"

# Terraform Apply
tf_apply:
	export GOOGLE_APPLICATION_CREDENTIALS=$(HOME)/terraform_key.json && \
	unset http_proxy && unset https_proxy && \
	cd infra-templates/terraform/config && \
	tfenv use $(TFVERSION) && \
	terraform workspace select $(TFWORKSPACE) || terraform workspace new $(TFWORKSPACE) && \
	terraform apply -var-file="../../../env-config/$(ENV)/terraform.tfvars"

# Git push configuration files created by Terraform
git_push:
	git add . && \
	git diff-index --quiet HEAD || git commit -m "committing repo back to git" && \
	git push

# Terraform Destroy
tf_destroy:
	export GOOGLE_APPLICATION_CREDENTIALS=$(HOME)/terraform_key.json && \
	unset http_proxy && unset https_proxy && \
	cd infra-templates/terraform/config && \
	tfenv use $(TFVERSION) && \
    terraform workspace select $(TFWORKSPACE) || terraform workspace new $(TFWORKSPACE) && \
	terraform destroy -var-file="../../../env-config/$(ENV)/terraform.tfvars"

######################################################################################################################################################
# GKE Infra Components

# Nginx Ingress Controller
ingress:
	cd infra-templates/ansible/playbooks && \
	ansible-playbook master_gke_playbook.yml --tags ingress -e="@../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml"

# Netapp CVO
cvo:
	cd infra-templates/ansible/playbooks && \
	ansible-playbook master_gke_playbook.yml --tags cvo -e="@../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml"

# Trident
trident:
	cd infra-templates/ansible/playbooks && \
	ansible-playbook master_gke_playbook.yml --tags trident -e="@../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml"

# Prometheus, Alert Manager and Grafana
prometheus:
	cd infra-templates/ansible/playbooks && \
	ansible-playbook master_gke_playbook.yml --tags prometheus -e="@../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml"

# Sectigo SSL Certificates
sectigo:
	cd infra-templates/ansible/playbooks && \
	ansible-playbook master_gke_playbook.yml --tags sectigo -e="@../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml"

# Velero for GKE backup
velero:
	cd infra-templates/ansible/playbooks && \
	ansible-playbook master_gke_playbook.yml --tags velero -e="@../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml"

# Check Zabbix Monitoring for the deployed VMs
zabbix_check:
	cd infra-templates/ansible/playbooks/roles && \
	ansible-playbook zabbix_monitoring/playbook.yml -e "zabbix_task_type=check" -e="@../../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_zabbix_inventory.yml"

# Enable Zabbix Monitoring for the deployed VMs
zabbix_enable:
	cd infra-templates/ansible/playbooks/roles && \
	ansible-playbook zabbix_monitoring/playbook.yml -e "zabbix_task_type=enable" -e="@../../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_zabbix_inventory.yml"

# Disable Zabbix Monitoring for the deployed VMs
zabbix_disable:
	cd infra-templates/ansible/playbooks/roles && \
	ansible-playbook zabbix_monitoring/playbook.yml -e "zabbix_task_type=disable" -e="@../../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_zabbix_inventory.yml"

# Add Prometheus Silence for GKE resource monitoring
prometheus_silence_add:
	cd infra-templates/ansible/playbooks/roles && \
    ansible-playbook prometheus_add_remove_silence/playbook.yml -e="@../../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml" -e "prometheus_activity_type=silence_add"

# Remove Prometheus Silence for GKE resource monitoring
prometheus_silence_remove:
	cd infra-templates/ansible/playbooks/roles && \
    ansible-playbook prometheus_add_remove_silence/playbook.yml -e="@../../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml" -e "prometheus_activity_type=silence_remove"

# Create New Relic Certificate Monitoring
nr_cert_monitoring:
	cd infra-templates/ansible/playbooks/roles && \
    ansible-playbook nr_cert_monitoring/nr_cert_playbook.yml -e="@../../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml"

# Deploy Postgres Database server
postgres:
	cd infra-templates/ansible/playbooks/postgres_playbook && \
	ansible-playbook playbooks/1-inventory_playbook.yml -e="@../../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_pg_vars.yml" && \
    ansible-playbook playbooks/2-postgres_playbook.yml --ask-pass --ask-become -e="@../../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_pg_vars.yml" -i "$(HOME)/$(CUSTOMER)-$(ENV)-inventory.yml"

cvs_nfs_driver:
	cd infra-templates/ansible/playbooks && \
	ansible-playbook master_gke_playbook.yml --tags cvs -e="@../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml"

gcp_managed_prometheus:
	cd infra-templates/ansible/playbooks && \
	ansible-playbook master_gke_playbook.yml --tags gmp -e="@../../../env-config/$(ENV)/$(CUSTOMER)_$(ENV)_master_vars.yml"

####################################################################################################################################################

help:
	@echo "TARGETS:"
	@make -qpRr | egrep -e '^[a-z].*:$$' | sed -e 's~:~~g' | sort
	@echo ""
