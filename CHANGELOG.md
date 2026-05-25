### What's changed in v1.3.0

* feat: tune crossplane resources and nodepool (#19) (by @patrickleet)

  Summary:
  - Add explicit resource requests/limits for Crossplane, rbac-manager, providers, and function-auto-ready runtime.
  - Align runtime requests with current target-cluster Goldilocks/VPA recommendations.
  - Rename the default dedicated NodePool from crossplane to hops-crossplane.
  - Ensure Crossplane, providers, rbac-manager, and function-auto-ready use crossplane nodepool placement when nodePool is enabled.

* chore(deps): update unbounded-tech/workflow-vnext-tag action to v1.21.3 (#14) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* chore(deps): update unbounded-tech/workflow-simple-release action to v2.1.3 (#13) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* feat(deps): update crossplane-contrib/provider-family-aws docker tag to v2.5.0 (#15) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* chore(deps): update unbounded-tech/workflows-crossplane action to v3 (#12) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>


See full diff: [v1.2.0...v1.3.0](https://github.com/hops-ops/aws-crossplane-stack/compare/v1.2.0...v1.3.0)
