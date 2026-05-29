# aws-crossplane-stack

Installs Crossplane core via Helm. Provider and function packages are
installed separately.

## Overview

`CrossplaneStack` is the core layer for a target cluster. It creates:

1. **Crossplane Helm Release** — Crossplane from the stable chart repo.
2. **Optional NodePool Object** — dedicated scheduling for Crossplane core pods.
3. **Usage safeguard** — deletion ordering when the NodePool is enabled.

It does not render target-cluster Provider packages, Function packages,
ProviderConfigs, DeploymentRuntimeConfigs, or PodIdentity. Install provider
packages with the provider-specific `Crossplane*Provider` XRs and function
packages with the `CrossplaneFunctions` XR under `xrs/stacks/crossplane`.

## Usage

### Minimal

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: CrossplaneStack
metadata:
  name: crossplane
  namespace: default
spec:
  clusterName: my-cluster
```

### With dedicated Crossplane nodes

```yaml
apiVersion: aws.hops.ops.com.ai/v1alpha1
kind: CrossplaneStack
metadata:
  name: crossplane
  namespace: default
spec:
  clusterName: production
  labels:
    team: platform
  install:
    values:
      resourcesCrossplane:
        requests:
          cpu: 500m
          memory: 1Gi
  nodePool:
    enabled: true
    nodeClassName: default
```

### Function packages

Function packages (e.g. `function-auto-ready`) are installed by the
`CrossplaneFunctions` XR (`xrs/stacks/crossplane/crossplane-functions`), not by
this stack.

### Next layer

After Crossplane core is healthy, install the provider-specific packages you
need, such as `CrossplaneAWSProvider`, `CrossplaneKubernetesProvider`, and
`CrossplaneHelmProvider`. Those provider XRs can set
`spec.nodePool.enabled: true` to use this stack's Crossplane NodePool, whose
default name remains `hops-crossplane`.

## Development

```bash
make render          # Render all examples
make validate        # Validate rendered output
make test            # Run KCL unit tests
make render:minimal  # Render single example
```
