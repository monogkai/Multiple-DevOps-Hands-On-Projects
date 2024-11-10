#!/bin/bash

# Ensure correct permissions for the SSH directory
chmod 700 ~/.ssh

KEY_PATH=~/.ssh/monokai-key-pair

# Remove all existing keys if they exist
if [ -f "$KEY_PATH" ]; then
    rm "$KEY_PATH" "$KEY_PATH.pub" 2>/dev/null
    echo "Removed existing SSH keys."
fi

# Create a new SSH key pair
if ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -C "estevesandre776@gmail.com" -N ""; then
    echo "SSH key pair created successfully."
else
    echo "Failed to create SSH key pair. Check permissions."
    exit 1
fi

# Set correct permissions for the private key
chmod 400 "$KEY_PATH"

# Add the private key to the SSH agent
ssh-add "$KEY_PATH"

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

cd ../ansible

# Update the inventory.ini file
cat <<EOL > inventory.ini
[monokai_instances]
$INSTANCE_IP ansible_ssh_private_key_file=$KEY_PATH ansible_user=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOL

echo "Updated inventory.ini with IP: $INSTANCE_IP"

# Wait for the instance to be ready
RETRY_COUNT=10
for ((i=1; i<=$RETRY_COUNT; i++)); do
    if ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" ubuntu@"$INSTANCE_IP" exit; then
        echo "SSH connection successful."
        break
    else
        echo "Waiting for instance to be ready... ($i/$RETRY_COUNT)"
        sleep 10
    fi
done

# Install setup
ansible-playbook -i inventory.ini setup-ec2.yml --user ubuntu --private-key "$KEY_PATH"
