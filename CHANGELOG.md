### What's changed in v0.6.0

* chore(makefile): swap hops config generate → hops validate generate-configuration (by @patrickleet)

  The generate-configuration subcommand moved from `hops config` to
  `hops validate` in hops-cli v0.19.x; the old invocation no longer
  exists. Updates the existing Makefile target to the new path.

  Implements [[tasks/update-xrd-makefiles-generate-config]]

* feat(deps): update dependency aws-pod-identity to v0.10.1 (#10) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>


See full diff: [v0.5.0...v0.6.0](https://github.com/hops-ops/aws-crossplane-stack/compare/v0.5.0...v0.6.0)
