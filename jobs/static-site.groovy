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