#!/bin/bash

source .env

cd ec2-instance/ansible

INSTANCE_IP=$(cat "../$IP_SAVED_FILENAME")

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

cd ..
cd ..