pipelineJob('helm-autoscaler-eks-remote-job') {
    triggers {
        githubPush()
    }
    definition {
        cpsScm {
            lightweight(true)
            scm {
                git {
                    remote {
                        url('https://github.com/cyse7125-su24-team12/helm-eks-autoscaler.git')
                        credentials('git-credentials-id')
                    }
                    branch('main')
                }
            }
            scriptPath('Jenkinsfile')
        }
    }
}
