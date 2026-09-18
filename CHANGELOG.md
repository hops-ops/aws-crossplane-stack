### What's changed in v1.15.0

* fix(deps): update helm release crossplane to v2.4.1 (by @renovate[bot])

  XR-rendered Crossplane chart patch: package revision ownership fix + security dependency bumps. Validate/e2e green.

* feat: own runtime service accounts and optional Helm ECR identity (#43) (by @patrickleet)

  * fix: preserve runtime service accounts across package revisions

  [[tasks/harmony-1750]]

  * feat: let HelmProviderStack own ECR pod identity [[tasks/harmony-1750]]

  * test: fix Helm observed resource fixture keys


See full diff: [v1.14.0...v1.15.0](https://github.com/hops-ops/aws-crossplane-stack/compare/v1.14.0...v1.15.0)
