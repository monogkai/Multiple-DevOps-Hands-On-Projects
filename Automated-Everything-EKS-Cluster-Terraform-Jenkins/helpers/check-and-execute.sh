#!/bin/bash

# Function to check if a file exists and is executable
function check_and_execute {
    local script_path="$1"
    if [ -f "$script_path" ]; then
        # Ensure the script has execute permissions
        chmod +x "$script_path"
        
        # Run the script
        echo "Running $script_path..."
        if "$script_path"; then
            echo "$script_path completed successfully."
        else
            echo "Error: $script_path failed." >&2
            exit 1
        fi
    else
        echo "Error: $script_path does not exist." >&2
        exit 1
    fi
}