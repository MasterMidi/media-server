#!/bin/bash

# Set the group name
group_name="media"

# Path to your docker-compose.yml file
compose_file="./docker-compose.yml"

# Extract container names from the docker-compose file
container_names=($(docker compose -f "$compose_file" config --services))

# Create the group if it doesn't exist
if ! getent group "$group_name" &>/dev/null; then
    sudo groupadd "$group_name"
fi

# Iterate over container names and create user accounts if they don't exist
for container_name in "${container_names[@]}"; do
    # Check if the user already exists (skip if it does)
    if ! id "$container_name" &>/dev/null; then
        sudo useradd -M -N -g "$group_name" -s /usr/sbin/nologin "$container_name"
        echo "User '$container_name' created."
    else
        echo "User '$container_name' already exists. Skipping."
    fi
done

# Print a message indicating the process is complete
echo "User accounts for specified containers created."
