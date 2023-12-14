#!/bin/bash

# Path to your Docker Compose file
compose_file="./docker-compose.yml"

# Path to your .env file
env_file="./.env"

# Iterate over services in the Docker Compose file
services=$(docker compose -f "$compose_file" config --services)

# Define an associative array to map service names to PUID values
declare -A service_variables

# Loop through services and extract PUID values from /etc/passwd
for service in $services; do
    # Check if the user exists in /etc/passwd
    if grep -q "^$service:" /etc/passwd; then
        # Extract PUID from /etc/passwd
        puid=$(id -u "$service")
        # Capitalize the service name
        capitalized_service=$(echo "$service" | tr '[:lower:]' '[:upper:]')
        service_variables["$capitalized_service"]=$puid
    else
        echo "Warning: No user entry found for service $service in /etc/passwd."
    fi
done

# Loop through services and update the .env file
for service in $services; do
    capitalized_service=$(echo "$service" | tr '[:lower:]' '[:upper:]')
    if [ "${service_variables[$capitalized_service]+exists}" ]; then
        puid="${service_variables[$capitalized_service]}"
        sed -i "s/^${capitalized_service}_PUID=.*/${capitalized_service}_PUID=$puid/g" "$env_file"
    else
        echo "Warning: No PUID value defined for service $service."
    fi
done

echo "User IDs in .env file updated."
