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