#!/bin/bash

source .env

# Ensure correct permissions for the SSH directory
chmod 700 ~/.ssh

# Remove all existing keys if they exist
if [ -f "$KEY_PATH" ]; then
    rm "$KEY_PATH" "$KEY_PATH.pub" 2>/dev/null
    echo "Removed existing SSH keys."
fi

# Create a new SSH key pair
if ssh-keygen -t rsa -b 2048 -f "$KEY_PATH" -C "$EMAIL" -N ""; then
    echo "SSH key pair created successfully."
else
    echo "Failed to create SSH key pair. Check permissions."
    exit 1
fi

# Set correct permissions for the private key
chmod 400 "$KEY_PATH"

# Add the private key to the SSH agent
ssh-add "$KEY_PATH"