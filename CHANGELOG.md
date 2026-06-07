### What's changed in v1.4.0

* feat: consolidate Crossplane Provider/Function APIs (#20) (by @patrickleet)

  * refactor: slim CrossplaneStack to Crossplane core only

  Extract provider and function installation out of CrossplaneStack into the
  dedicated crossplane-<x>-provider-stack and crossplane-functions-stack
  configurations. CrossplaneStack now renders only the Crossplane Helm release,
  the optional dedicated NodePool, and the protection Usage. Removes the
  spec.providers / spec.aws / spec.functions surfaces and their render templates.

  Non-breaking: the stack is not yet consumed downstream.

  Implements [[tasks/crossplane-stack-core-only]] [[tasks/crossplane-functions-xr]]

  Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>

  * feat: consolidate Crossplane bootstrap APIs

  ---------

  Co-authored-by: Claude Opus 4.8 (1M context) <noreply@anthropic.com>

* feat(deps): update dependency provider-openpanel to v1.1.0 (#21) (by @renovate[bot])

  Co-authored-by: renovate[bot] <29139614+renovate[bot]@users.noreply.github.com>


See full diff: [v1.3.0...v1.4.0](https://github.com/hops-ops/aws-crossplane-stack/compare/v1.3.0...v1.4.0)
