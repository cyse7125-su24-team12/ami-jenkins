pipeline {
  agent any
  environment {
    DOCKERHUB_REPO = 'bala699/csye7125'
    BUILD_NUMBER = "latest"
  }
  stages {
    stage('Setup Buildx') {
      steps {
        script {
          sh '''
            mkdir -p ~/.docker/cli-plugins/
            curl -sL https://github.com/docker/buildx/releases/download/v0.14.1/buildx-v0.14.1.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
            chmod +x ~/.docker/cli-plugins/docker-buildx
            export PATH=$PATH:~/.docker/cli-plugins
          '''
        }
      }
    }
    stage('Checkout') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/main']],
             doGenerateSubmoduleConfigurations: false,
             extensions: [[$class: 'CleanCheckout']],
             submoduleCfg: [],
             userRemoteConfigs: [[url: "https://BalasubramanianU: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@github.com/BalasubramanianU/static-site-remote.git", credentialsId: 'git-credentials-id']]
        ])
      }
    }
    stage('Build and push the docker image using buildx') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
          script {
            sh '''
            # Login to Docker Hub
            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

            # Create and use builder instance
            docker buildx create --use

            # Build and push Docker image
            docker buildx build --platform linux/amd64,linux/arm64 -t ${DOCKERHUB_REPO}:${BUILD_NUMBER} --push .

            # Logout from Docker Hub
            docker logout
            '''
          }
        }
      }
    }
  }
  post {
    success {
      echo 'Docker image pushed successfully!'
    }
    failure {
      echo 'Docker image push failed!'
    }
  }
}