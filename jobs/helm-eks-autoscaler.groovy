multibranchPipelineJob('helm-eks-autoscaler') {
    branchSources {
        github {
            id('csye7125-su24-t12-helm-eks-autoscaler')
            scanCredentialsId('git-credentials-id')
            repoOwner('cyse7125-su24-team12')
            repository('helm-eks-autoscaler')
            buildForkPRMerge(true)
            buildOriginBranch(false)
            buildOriginBranchWithPR(false)
        }
    }
}
