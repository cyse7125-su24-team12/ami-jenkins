#!/bin/bash

# Install Jenkins on Ubuntu 20.04
echo "Downloading Jenkins for installation .."

#installing Java
sudo apt-get update
sudo apt install fontconfig openjdk-17-jre -y

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins -y

echo "Jenkins installed successfully"

sudo ls -a /var/lib/jenkins/

sudo cat /var/lib/jenkins/secrets/initialAdminPassword

## starting jenkins 
sudo systemctl start jenkins
sudo systemctl status jenkins

## enabling jenkins
sudo systemctl enable jenkins

## opening port 8080
sudo ufw allow 8080
sudo ufw allow 80 
sudo ufw allow OpenSSH
echo "yes" | sudo ufw enable
sudo ufw status

# Copying credentials from packer environment to linux environment
sudo mkdir -p /etc/jenkins
CREDS_FILE="/etc/jenkins/.env.test"

sudo tee -a $CREDS_FILE > /dev/null << EOF
username=$ADMIN_USERNAME
password=$ADMIN_PASSWORD
git_username=$GIT_USERNAME
git_access_token=$GIT_ACCESS_TOKEN
docker_username=$DOCKER_USERNAME
docker_access_token=$DOCKER_ACCESS_TOKEN
github_pat=$GITHUB_PAT   
EOF

# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io
# Add Jenkins user to Docker group
sudo usermod -aG docker jenkins

# Install terraform - from official docs
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform

# Install packer - from official docs
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer

# Install yamllint
sudo apt-get update && sudo apt-get install -y yamllint
