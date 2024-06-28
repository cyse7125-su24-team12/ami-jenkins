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
  "conventional-commits"
  "nodejs"
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
echo "git username: $git_username"
echo "git access token: $git_access_token"
echo "docker username: $docker_username"
echo "docker access token: $docker_access_token"
echo "github pat: $github_pat"

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

# Ensure the JCasC configuration directory exists
sudo mkdir -p /etc/jenkins

# Create the groovy script for single pipeline job - static site - A02
sudo tee /etc/jenkins/static-site-remote-job.groovy > /dev/null <<EOF
pipelineJob('static-site-remote-job') {
  triggers {
    githubPush()
  }
  definition {
    cpsScm {
      lightweight(true)
      scm {
        git {
          remote {
            url('https://github.com/cyse7125-su24-team12/static-site.git')
            credentials('git-credentials-id')
          }
          branch('main')
        }
      }
      scriptPath('Jenkinsfile')
    }
  }
}
EOF

#create the groovy script for single pipeline job - helm-webapp-cve-processor - A03
sudo tee /etc/jenkins/helm-webapp-cve-processor-remote-job.groovy > /dev/null <<EOF
pipelineJob('helm-webapp-cve-processor-remote-job') {
  triggers {
    githubPush()
  }
  definition {
    cpsScm {
      lightweight(true)
      scm {
        git {
          remote {
            url('https://github.com/cyse7125-su24-team12/helm-webapp-cve-processor.git')
            credentials('git-credentials-id')
          }
          branch('main')
        }
      }
      scriptPath('Jenkinsfile')
    }
  }
}
EOF

#create the groovy script for single pipeline job - helm-webapp-cve-processor - A03
sudo tee /etc/jenkins/webapp-cve-processor-remote-job.groovy > /dev/null <<EOF
pipelineJob('webapp-cve-processor-remote-job') {
  triggers {
    githubPush()
  }
  definition {
    cpsScm {
      lightweight(true)
      scm {
        git {
          remote {
            url('https://github.com/cyse7125-su24-team12/webapp-cve-processor.git')
            credentials('git-credentials-id')
          }
          branch('main')
        }
      }
      scriptPath('Jenkinsfile')
    }
  }
}
EOF

#create the groovy script for single pipeline job - webapp-cve-consumer - A05
sudo tee /etc/jenkins/webapp-cve-consumer-remote-job.groovy > /dev/null <<EOF
pipelineJob('webapp-cve-consumer-remote-job') {
  triggers {
    githubPush()
  }
  definition {
    cpsScm {
      lightweight(true)
      scm {
        git {
          remote {
            url('https://github.com/cyse7125-su24-team12/webapp-cve-consumer.git')
            credentials('git-credentials-id')
          }
          branch('main')
        }
      }
      scriptPath('Jenkinsfile')
    }
  }
}
EOF

#create the groovy script for single pipeline job - helm-webapp-cve-consumer - A05
sudo tee /etc/jenkins/helm-webapp-cve-consumer-remote-job.groovy > /dev/null <<EOF
pipelineJob('helm-webapp-cve-consumer-remote-job') {
  triggers {
    githubPush()
  }
  definition {
    cpsScm {
      lightweight(true)
      scm {
        git {
          remote {
            url('https://github.com/cyse7125-su24-team12/helm-webapp-cve-consumer.git')
            credentials('git-credentials-id')
          }
          branch('main')
        }
      }
      scriptPath('Jenkinsfile')
    }
  }
}
EOF

# Create the groovy script for multibranch pipeline - static-site
sudo tee /etc/jenkins/static-site-job.groovy > /dev/null <<EOF
multibranchPipelineJob('static-site-job') {
  branchSources {
    github {
      id('csye7125-su24-t12-static-site')
      scanCredentialsId('git-credentials-id')
      repoOwner('cyse7125-su24-team12')
      repository('static-site')
      buildForkPRMerge(true)
      buildOriginBranch(false)
      buildOriginBranchWithPR(false)
    }
  }
}
EOF

# Create the groovy script for multibranch pipeline - infra-jenkins
sudo tee /etc/jenkins/infra-jenkins-job.groovy > /dev/null <<EOF
multibranchPipelineJob('infra-jenkins-job') {
  branchSources {
    github {
      id('csye7125-su24-t12-infra-jenkins')
      scanCredentialsId('git-credentials-id')
      repoOwner('cyse7125-su24-team12')
      repository('infra-jenkins')
      buildForkPRMerge(true)
      buildOriginBranch(false)
      buildOriginBranchWithPR(false)
    }
  }
}
EOF

# Create the groovy script for multibranch pipeline - k8s-yaml-manifests
sudo tee /etc/jenkins/k8s-yaml-manifests-job.groovy > /dev/null <<EOF
multibranchPipelineJob('k8s-yaml-manifests-job') {
  branchSources {
    github {
      id('csye7125-su24-t12-k8s-yaml-manifests')
      scanCredentialsId('git-credentials-id')
      repoOwner('cyse7125-su24-team12')
      repository('k8s-yaml-manifests')
      buildForkPRMerge(true)
      buildOriginBranch(false)
      buildOriginBranchWithPR(false)
    }
  }
}
EOF

# Create the groovy script for multibranch pipeline - ami-jenkins
sudo tee /etc/jenkins/ami-jenkins-job.groovy > /dev/null <<EOF
multibranchPipelineJob('ami-jenkins-job') {
  branchSources {
    github {
      id('csye7125-su24-t12-ami-jenkins')
      scanCredentialsId('git-credentials-id')
      repoOwner('cyse7125-su24-team12')
      repository('ami-jenkins')
      buildForkPRMerge(true)
      buildOriginBranch(false)
      buildOriginBranchWithPR(false)
    }
  }
}
EOF

#Create the groove script for multibranch pipeline - helm-webapp-cve-processor 
sudo tee /etc/jenkins/helm-webapp-cve-processor-job.groovy > /dev/null <<EOF
multibranchPipelineJob('helm-webapp-cve-processor-job') {
  branchSources {
    github {
      id('csye7125-su24-t12-helm-webapp-cve-processor')
      scanCredentialsId('git-credentials-id')
      repoOwner('cyse7125-su24-team12')
      repository('helm-webapp-cve-processor')
      buildForkPRMerge(true)
      buildOriginBranch(false)
      buildOriginBranchWithPR(false)
    }
  }
}
EOF

#Create the groovy script for multibranch pipeline - go-webapp-cve-processor
sudo tee /etc/jenkins/webapp-cve-processor-job.groovy > /dev/null <<EOF
multibranchPipelineJob('webapp-cve-processor-job') {
  branchSources {
    github {
      id('csye7125-su24-t12-webapp-cve-processor')
      scanCredentialsId('git-credentials-id')
      repoOwner('cyse7125-su24-team12')
      repository('webapp-cve-processor')
      buildForkPRMerge(true)
      buildOriginBranch(false)
      buildOriginBranchWithPR(false)
    }
  }
}
EOF

#Create the groovy script for multibranch pipeline - infra-aws
sudo tee /etc/jenkins/infra-aws.groovy > /dev/null <<EOF
multibranchPipelineJob('infra-aws-job') {
  branchSources {
    github {
      id('csye7125-su24-t12-infra-aws')
      scanCredentialsId('git-credentials-id')
      repoOwner('cyse7125-su24-team12')
      repository('infra-aws')
      buildForkPRMerge(true)
      buildOriginBranch(false)
      buildOriginBranchWithPR(false)
    }
  }
}
EOF

#Create the groove script for multibranch pipeline - helm-webapp-cve-processor 
sudo tee /etc/jenkins/helm-webapp-cve-consumer-job.groovy > /dev/null <<EOF
multibranchPipelineJob('helm-webapp-cve-consumer-job') {
  branchSources {
    github {
      id('csye7125-su24-t12-helm-webapp-cve-consumer')
      scanCredentialsId('git-credentials-id')
      repoOwner('cyse7125-su24-team12')
      repository('helm-webapp-cve-consumer')
      buildForkPRMerge(true)
      buildOriginBranch(false)
      buildOriginBranchWithPR(false)
    }
  }
}
EOF

#Create the groovy script for multibranch pipeline - go-webapp-cve-processor
sudo tee /etc/jenkins/webapp-cve-consumer-job.groovy > /dev/null <<EOF
multibranchPipelineJob('webapp-cve-consumer-job') {
  branchSources {
    github {
      id('csye7125-su24-t12-webapp-cve-consumer')
      scanCredentialsId('git-credentials-id')
      repoOwner('cyse7125-su24-team12')
      repository('webapp-cve-consumer')
      buildForkPRMerge(true)
      buildOriginBranch(false)
      buildOriginBranchWithPR(false)
    }
  }
}
EOF

# Create the JCasC YAML configuration file
sudo tee /etc/jenkins/jenkins.yaml > /dev/null <<EOF
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              scope: GLOBAL
              id: git-credentials-id
              description: Github Credentials
              username: $git_username
              password: $git_access_token
          - usernamePassword:
              scope: GLOBAL
              id: dockerhub-credentials-id
              description: DockerHub Credentials
              username: $docker_username
              password: $docker_access_token
          - string:
              scope: GLOBAL
              id: github-pat
              description: Github Personal Access Token
              secret: $github_pat
tool:
  nodejs:
    installations:
    - name: "Node 20"
      properties:
      - installSource:
          installers:
          - nodeJSInstaller:
              id: "22.2.0"
              npmPackagesRefreshHours: 72
jobs:
  - file: /etc/jenkins/static-site-remote-job.groovy
  - file: /etc/jenkins/static-site-job.groovy
  - file: /etc/jenkins/infra-jenkins-job.groovy
  - file: /etc/jenkins/k8s-yaml-manifests-job.groovy
  - file: /etc/jenkins/ami-jenkins-job.groovy
  - file: /etc/jenkins/helm-webapp-cve-processor-remote-job.groovy
  - file: /etc/jenkins/helm-webapp-cve-processor-job.groovy
  - file: /etc/jenkins/webapp-cve-processor-job.groovy
  - file: /etc/jenkins/webapp-cve-processor-remote-job.groovy
  - file: /etc/jenkins/infra-aws.groovy
  - file: /etc/jenkins/helm-webapp-cve-consumer-job.groovy
  - file: /etc/jenkins/helm-webapp-cve-consumer-remote-job.groovy
  - file: /etc/jenkins/webapp-cve-consumer-job.groovy
  - file: /etc/jenkins/webapp-cve-consumer-remote-job.groovy

EOF

echo "JCasC configuration created and saved to /etc/jenkins/jenkins.yaml"

# Restart Jenkins to apply changes
sudo systemctl restart jenkins

# Verify the plugin installation
echo "Installed plugins:"
java -jar $JENKINS_CLI_JAR -s $JENKINS_URL -auth "$ADMIN_USERNAME":"$ADMIN_PASSWORD" list-plugins | grep -E "$(IFS='|'; echo "${PLUGINS[*]}")"


# Modify the environment variable of jenkins.service to disable the setup wizard 
# and load jcasc configuration
sudo mkdir -p /etc/systemd/system/jenkins.service.d/
{
  echo "[Service]"
  echo "Environment=\"JAVA_OPTS=-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=/etc/jenkins/jenkins.yaml\""
} | sudo tee /etc/systemd/system/jenkins.service.d/override.conf

# Reload the systemd manager configuration to pickup the new config changes
sudo systemctl daemon-reload

# Restart Jenkins to apply the changes
sudo systemctl restart jenkins

# Verify the job creation
echo "Created jobs:"
java -jar $JENKINS_CLI_JAR -s $JENKINS_URL -auth "$ADMIN_USERNAME":"$ADMIN_PASSWORD" list-jobs

# To allow jenkins user to run sudo commands in the groovy scripts inside job DSLs
# The user for whom to enable passwordless sudo
USERNAME="jenkins"
# Temporary file for sudoers changes
TMP_FILE=$(mktemp)
# Create a new sudoers file entry
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > "$TMP_FILE"
# Check syntax and update sudoers if OK
visudo -c -f "$TMP_FILE" && cat "$TMP_FILE" | sudo EDITOR="tee -a" visudo
# Cleanup temporary file
rm "$TMP_FILE"
