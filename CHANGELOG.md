### What's changed in v0.2.0

* chore: file-based env vars for e2e tests (#1) (by @patrickleet)

  * feat: use file-based env vars for e2e tests

  Replace hardcoded AWS account IDs, subnet IDs, and other
  environment-specific values with file.read("env/...") pattern.
  CI writes env files from GitHub repo variables (${{ vars.* }}).
  Workflow versions updated to v2.19.1 + feat/kcl-env-files.

  Implements [[tasks/e2e-env-vars-via-files]]

  * chore: use e2e workflow v2.19.1 (released)

  Update e2e workflow ref from feat/kcl-env-files to v2.19.1.

  * chore: add write-env-files: true for explicit env file opt-in

  * chore: update workflows-crossplane to v2.20.0 (write-env-files support)

* feat(deps): update crossplane-contrib/provider-upjet-github docker tag to v0.19.0 (#6) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>

* feat(deps): update crossplane-contrib/provider-family-aws docker tag to v2.5.0 (#5) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>


See full diff: [v0.1.0...v0.2.0](https://github.com/hops-ops/aws-crossplane-stack/compare/v0.1.0...v0.2.0)
