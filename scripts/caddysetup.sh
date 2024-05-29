#!/bin/bash

sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/testing/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-testing-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/testing/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-testing.list
sudo apt update
sudo apt install caddy

# Define the Caddyfile content
CADDYFILE_CONTENT="jenkins.cloudnativewebapp.me {
    reverse_proxy :8080
}"

# Write the content to the Caddyfile in the current directory
echo "$CADDYFILE_CONTENT" > Caddyfile

# sudo caddy stop
sudo caddy reload


echo "Caddy installed & proxy updated successfully"
