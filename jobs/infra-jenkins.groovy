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