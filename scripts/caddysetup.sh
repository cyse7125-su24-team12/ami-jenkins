#!/bin/bash

# Install required packages
sudo apt-get update
sudo apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl

# Add Caddy's GPG key and repository
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/testing/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-testing-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/testing/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-testing.list

# Update package list and install Caddy
sudo apt-get update
sudo apt-get install -y caddy

# Create the certificates directory and set permissions (fix for error)
sudo mkdir -p /var/lib/caddy/.local/share/caddy/pki/authorities/local
sudo chown -R caddy:caddy /var/lib/caddy/.local/share/caddy
sudo chmod -R 0755 /var/lib/caddy/.local/share/caddy

# Define the Caddyfile content (improved)
CADDYFILE_CONTENT="
{
        acme_ca https://acme-staging-v02.api.letsencrypt.org/directory
}
 
jenkins.cloudnativewebapp.me {
        reverse_proxy :8080
}
"

# Write the content to the Caddyfile in the appropriate directory
echo "$CADDYFILE_CONTENT" | sudo tee /etc/caddy/Caddyfile

# Format the Caddyfile for better readability (optional)
sudo caddy fmt --overwrite /etc/caddy/Caddyfile

sudo service caddy restart

sudo ufw allow 443

sudo ufw reload

echo "Caddy installed & proxy updated successfully"
