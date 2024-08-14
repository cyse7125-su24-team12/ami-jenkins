multibranchPipelineJob('helm-webapp-llm-job') {
    branchSources {
        github {
            id('csye7125-su24-t12-helm-webapp-llm')
            scanCredentialsId('git-credentials-id')
            repoOwner('cyse7125-su24-team12')
            repository('helm-webapp-llm')
            buildForkPRMerge(true)
            buildOriginBranch(false)
            buildOriginBranchWithPR(false)
        }
    }
}