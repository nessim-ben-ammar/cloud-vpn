# Terraform variables configuration
# This file contains the default values for variables defined in variables.tf

# AWS region where resources will be deployed
region = "us-east-1"

# Deploy AWS Global Accelerator to expose a stable DNS
deploy_global_accelerator = false

# Attach an Elastic IP to the instance for a persistent public IP
assign_elastic_ip = false
