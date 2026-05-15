### What's changed in v0.8.0

* feat: zitadel provider toggle + resource-name cleanup + nodepool (by @patrickleet)

  * Adds providers.zitadel.{enabled, runtimeConfig} that installs
    crossplane-contrib/provider-upjet-zitadel:v0.1.1 (DRC + Provider
    package). ProviderConfig lives in AuthStack — see
    tasks/authstack-provider-zitadel-config.

  * Drops the <xr.name>- prefix from every composed-resource
    metadata.name per specs/stack-composition-namespacing — XR namespace
    already identifies the cluster. Inner ProviderConfig.metadata.name
    is unchanged (still defaults to clusterName, downstream contract).

  * nodePool.enabled now also auto-populates the crossplane chart's
    nodeSelector + tolerations (core + rbacManager) so the dedicated
    pool hosts the entire stack, not just provider pods. Default
    capacity-type flipped to spot with a broader m/c instance family
    list for spot availability.

  * Both deletion-order Usages (delete-aws-before-pod-identity,
    delete-crossplane-before-nodepool) now render unconditionally —
    gating these safeguards on observed readiness was a footgun where
    a transient Ready=False on a dep would un-render the protection
    at exactly the wrong moment.

  * 001-state-observed-providers reads the Object MR's Ready condition
    (the previously-used Installed condition only exists on direct
    Provider MRs, never on Object wrappers).

  * Drops cluster-name prefix on the inner Karpenter NodePool target
    (spec.nodePool.name override exposed for the rare two-pools case).

  Renames every composed MR (e.g. crossplane-providerconfig-aws ->
  providerconfig-aws). Stack is pre-1.0 / alpha; no external consumers
  existed yet — first end-to-end install on pat-local in this same
  change set.

* feat: pin every composed package with skipDependencyResolution: true (by @patrickleet)

  Every composed Provider and Function MR now sets
  spec.skipDependencyResolution: true so Crossplane never silently
  auto-installs a transitive dep at a version the platform's
  GitOps + Renovate flow didn't pick. All package versions are
  declared explicitly in this stack; auto-resolution would
  silently undermine that contract.

  Affects: family-aws, aws sub-providers (iam, s3, ec2, eks, rds,
  lambda), kubernetes, helm, github, zitadel, function-auto-ready.

  New KCL test 'all-packages-pinned-with-skip-dependency-resolution'
  enables every provider + function and asserts the field renders
  on each (12 assertions). 11/11 KCL tests pass. make render +
  make validate clean across minimal/standard/full (31 resources).

  Validated end-to-end: applied via 'hops config install' to colima;
  CrossplaneStack XR reconciled; every Provider + Function on
  pat-local reflects spec.skipDependencyResolution: true.

  Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>


See full diff: [v0.7.0...v0.8.0](https://github.com/hops-ops/aws-crossplane-stack/compare/v0.7.0...v0.8.0)
