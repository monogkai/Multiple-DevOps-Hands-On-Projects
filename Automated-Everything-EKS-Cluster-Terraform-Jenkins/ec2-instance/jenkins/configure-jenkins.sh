#!/bin/bash

# Load environment variables from .env file
source .env

# Navigate to the Jenkins configuration directory
cd ec2-instance/jenkins

# Get the Jenkins instance IP address
INSTANCE_IP=$(cat "../$IP_SAVED_FILENAME")

# Jenkins URL and API endpoint
JENKINS_URL="http://$INSTANCE_IP:8080"
JENKINS_API_URL="$JENKINS_URL/jenkins/api/json"
JENKINS_CLI_URL="$JENKINS_URL/jenkins/cli/"

# Read the initial Jenkins admin password from the file
INITIAL_PASSWORD_FILE="initialAdminPassword"
INITIAL_PASSWORD=$(cat "$INITIAL_PASSWORD_FILE")