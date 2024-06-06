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
echo "Install Java " 
sudo apt update
sudo apt install fontconfig openjdk-17-jre -y
java -version

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

echo "Jenkins installed successfully"


sudo mkdir -p /etc/jenkins
CREDS_FILE="/etc/jenkins/.env.test"

sudo tee -a $CREDS_FILE > /dev/null << EOF
username=$ADMIN_USERNAME
password=$ADMIN_PASSWORD
git_username=$GIT_USERNAME
git_access_token=$GIT_ACCESS_TOKEN
docker_username=$DOCKER_USERNAME
docker_access_token=$DOCKER_ACCESS_TOKEN
EOF

# Install Docker
sudo apt-get update
sudo apt-get install -y docker.io

# Add Jenkins user to Docker group
sudo usermod -aG docker jenkins

