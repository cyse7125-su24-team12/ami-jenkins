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