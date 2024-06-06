#!/bin/bash

# Variables
JENKINS_URL="http://localhost:8080"
JENKINS_CLI_JAR_URL="$JENKINS_URL/jnlpJars/jenkins-cli.jar"
# JENKINS_ADMIN_PASSWORD_FILE="/var/lib/jenkins/secrets/initialAdminPassword"
JENKINS_CLI_JAR="jenkins-cli.jar"
NEW_ADMIN_USER="admin"
# NEW_ADMIN_PASSWORD="admin"
OLD_ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
SCRIPT_CONSENT_FILE="/var/lib/jenkins/init.groovy.d/disable-setup-wizard.groovy"

sudo ls -a /var/lib/jenkins/

sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "$OLD_ADMIN_PASSWORD"
# List of plugins to install
PLUGINS=(
  "aws-credentials"
  "credentials-binding"
  "timestamper"
  "ws-cleanup"
  "ant"
  "gradle"
  "workflow-aggregator"
  "github-branch-source"
  "pipeline-github"
  "workflow-cps-global-lib"
  "pipeline-stage-view"
  "git"
  "ssh-credentials"
  "matrix-auth"
  "pam-auth"
  "ldap"
  "email-ext"
  "mailer"
  "dark-theme"
  "antisamy-markup-formatter"
  "build-timeout"
  "cloudbees-folder"
  "configuration-as-code"
  "pipeline-github-lib"
  "ssh-slaves"
  "authorize-project"
  "docker-workflow"
  "docker-plugin"
  "job-dsl"
  "github"
)


# Function to check if Jenkins is up
check_jenkins() {
  while ! curl -sL "$JENKINS_URL" >/dev/null; do
    echo "Waiting for Jenkins to be up..."
    sleep 10
  done
  echo "Jenkins is up!"
}

# Download jenkins-cli.jar
wget -O $JENKINS_CLI_JAR $JENKINS_CLI_JAR_URL

# # Check if the password file exists
# if [[ -f "$JENKINS_ADMIN_PASSWORD_FILE" ]]; then
#   JENKINS_ADMIN_PASSWORD=$(sudo cat "$JENKINS_ADMIN_PASSWORD_FILE")
# else
#   echo "Admin password file not found!"
#   exit 1
# fi

# Wait for Jenkins to be fully up and running
check_jenkins

# Install each plugin
for PLUGIN in "${PLUGINS[@]}"; do
  echo "Installing plugin: $PLUGIN"
  java -jar $JENKINS_CLI_JAR -s $JENKINS_URL -auth $NEW_ADMIN_USER:"$OLD_ADMIN_PASSWORD" install-plugin "$PLUGIN" -deploy
done

# Restart Jenkins to apply changes
sudo systemctl restart jenkins 

# Disable the setup wizard
echo "Disabling the setup wizard..."
sudo mkdir -p /var/lib/jenkins/init.groovy.d
sudo tee $SCRIPT_CONSENT_FILE > /dev/null <<EOF
#!groovy

import jenkins.model.*
import hudson.util.*;
import jenkins.install.*;

def instance = Jenkins.getInstance()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
EOF

# creating admin user with password
# Load the environment variables from the .env.test file
export $(grep -v '^#' /etc/jenkins/.env.test | xargs)
echo "Creating admin user..."
echo "Username: $username"
echo "Password: $password"
sudo tee /var/lib/jenkins/init.groovy.d/createadmin.groovy > /dev/null <<EOF
/*
 * Create an admin user.
 */
import jenkins.model.*
import hudson.security.*

println "--> creating admin user"


def adminUsername = "$username"
def adminPassword = "$password"

assert adminPassword != null : "No ADMIN_USERNAME env var provided, but required"
assert adminPassword != null : "No ADMIN_PASSWORD env var provided, but required"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
Jenkins.instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
Jenkins.instance.setAuthorizationStrategy(strategy)

Jenkins.instance.save()
EOF

# Restart Jenkins to apply changes
sudo systemctl restart jenkins

# Verify the plugin installation
echo "Installed plugins:"
java -jar $JENKINS_CLI_JAR -s $JENKINS_URL -auth "$ADMIN_USERNAME":"$ADMIN_PASSWORD" list-plugins | grep -E "$(IFS='|'; echo "${PLUGINS[*]}")"


#add to jenkins.service

# Append the environment variable to disable the setup wizard
echo 'Environment="JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"' | sudo tee -a /lib/systemd/system/jenkins.service

# Reload the systemd manager configuration
sudo systemctl daemon-reload

# Restart Jenkins to apply the changes
sudo systemctl restart jenkins

sudo tee /var/lib/jenkins/init.groovy.d/create_git_credentials.groovy > /dev/null <<EOF
/*
 * Create GitHub credentials.
 */
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*

println "--> creating GitHub credentials"

def instance = Jenkins.getInstance()

def domain = Domain.global()
def credentialsStore = instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

def credentials = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  "git-credentials-id",
  "Github Credentials",
  "BalasubramanianU",
  "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"
)

credentialsStore.addCredentials(domain, credentials)

instance.save()
EOF

sudo tee /var/lib/jenkins/init.groovy.d/create_dockerhub_credentials.groovy > /dev/null <<EOF
/*
 * Create DockerHub credentials.
 */
import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*

println "--> creating DockerHub credentials"

def instance = Jenkins.getInstance()

def domain = Domain.global()
def credentialsStore = instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

def credentials = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  "dockerhub-credentials-id",
  "dockerhub Credentials",
  "bala699",
  "dckr_pat_28RzEezCZzKCpjnHQ2eGBVVHKNk"
)

credentialsStore.addCredentials(domain, credentials)

instance.save()
EOF

sudo tee /var/lib/jenkins/init.groovy.d/create_pipeline_job.groovy > /dev/null << EOF
import jenkins.model.Jenkins
import hudson.model.FreeStyleProject
import javaposse.jobdsl.plugin.ExecuteDslScripts

def jenkinsInstance = Jenkins.instance
def seedJobName = 'seed'

// Check if the 'seed' job exists and delete it if it does
def existingJob = jenkinsInstance.getItem(seedJobName)
if (existingJob != null) {
    existingJob.delete()
    println "Existing seed job deleted"
}

// Create a new freestyle project named 'seed'
def seedJob = jenkinsInstance.createProject(FreeStyleProject, seedJobName)

// Add a build step to process job DSL
def dslBuilder = new ExecuteDslScripts()
dslBuilder.setScriptText("""pipelineJob('static-site-remote-job') {
    triggers {
        githubPush()
    }
    definition {
        cpsScm {
            lightweight(true)
            scm {
                git {
                    remote {
                        url('https://github.com/BalasubramanianU/static-site-remote.git')
                        credentials('git-credentials-id')
                    }
                    branch('main')
                }
            }
            scriptPath('Jenkinsfile')
        }
    }
}""")
dslBuilder.setUseScriptText(true)
seedJob.buildersList.add(dslBuilder)

// Save the job configuration
seedJob.save()

// Trigger the seed job to run
jenkinsInstance.queue.schedule(seedJob)

// Save the overall Jenkins configuration
jenkinsInstance.save()

println "Seed job created and run successfully"
EOF

# Restart Jenkins to apply changes
sudo systemctl restart jenkins


# Verify the job creation
echo "Created jobs:"
java -jar $JENKINS_CLI_JAR -s $JENKINS_URL -auth "$ADMIN_USERNAME":"$ADMIN_PASSWORD" list-jobs

