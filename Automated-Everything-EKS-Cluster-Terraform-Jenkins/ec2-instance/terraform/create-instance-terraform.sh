#!/bin/bash

source .env

# Create EC2 Instance
cd ec2-instance/terraform

# Initialize Terraform
terraform init

# Remove all existing resources
terraform destroy -auto-approve

# Plan Terraform changes
terraform plan

# Apply Terraform changes with auto-approve
terraform apply -auto-approve

# Extract the public IP from the Terraform output
INSTANCE_IP=$(terraform output -raw instance_ip)
echo "Extracted INSTANCE_IP: $INSTANCE_IP"

# Write the instance IP to the target file
echo "$INSTANCE_IP" > "../$IP_SAVED_FILENAME"

cd ..
cd ..