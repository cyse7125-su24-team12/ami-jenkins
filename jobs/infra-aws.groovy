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