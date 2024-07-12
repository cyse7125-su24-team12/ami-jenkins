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