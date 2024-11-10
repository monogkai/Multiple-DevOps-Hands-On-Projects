#!/bin/bash

# Source the helper functions file
source ./helpers/check-and-execute.sh

# Run Permission Keys Creation Script
check_and_execute "./create-permission-keys.sh"

# Run Terraform Script to Create EC2 Instance
check_and_execute "./ec2-instance/terraform/create-instance-terraform.sh"

# Run Ansible Script to Add Dependencies
check_and_execute "./ec2-instance/ansible/add-dependencies-ansible.sh"

# Configurate Jenkins
check_and_execute "./ec2-instance/jenkins/configure-jenkins.sh"

echo "All tasks completed successfully."
