### What's changed in v1.0.0

* feat: require >=8GiB memory and >=2 vCPU in default NodePool requirements (by @patrickleet)

  BREAKING CHANGE: Karpenter could previously pick c.large (4 GiB) for the dedicated
  crossplane pool, leaving providers vulnerable to OOM under reconcile
  load. Default now adds eks.amazonaws.com/instance-memory > 7999 and
  instance-cpu > 1 to the requirements list.

  BREAKING CHANGE: existing CrossplaneStacks using the default
  requirements will see Karpenter mark sub-8GiB nodes as drifted and
  replace them on next reconcile.

* feat(deps): update crossplane-contrib/function-auto-ready docker tag to v0.6.5 (#16) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>


See full diff: [v0.8.0...v1.0.0](https://github.com/hops-ops/aws-crossplane-stack/compare/v0.8.0...v1.0.0)
