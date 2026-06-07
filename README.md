# aws-crossplane-stack

Installs Crossplane core via Helm and publishes the provider/function stack APIs
used to bootstrap a target Crossplane control plane.

## Overview

`CrossplaneStack` is the core layer for a target cluster. It creates:

1. **Crossplane Helm Release** — Crossplane from the stable chart repo.
2. **Optional NodePool Object** — dedicated scheduling for Crossplane core pods.
3. **Usage safeguard** — deletion ordering when the NodePool is enabled.

It does not render target-cluster Provider packages, Function packages,
ProviderConfigs, DeploymentRuntimeConfigs, or PodIdentity. Those concerns stay
separate XRs in this same configuration package:

- `FunctionsStack`
- `AWSProviderStack`
- `GitHubProviderStack`
- `HelmProviderStack`
- `KubernetesProviderStack`
- `ListmonkProviderStack`
- `OpenPanelProviderStack`
- `ZitadelProviderStack`

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
    nodeClassName: hops-default
```

When enabled, the Crossplane NodePool defaults to cheap, flexible Spot capacity:
c/m/r/t instance categories, generation 4 or newer, Linux, and no architecture
pin. Workloads that require x86 images should set
`nodeSelector: {kubernetes.io/arch: amd64}` or equivalent affinity.

### Function packages

Function packages such as `function-auto-ready` are installed by
`FunctionsStack`, not by `CrossplaneStack`.

### Next layer

After Crossplane core is healthy, install the provider-specific packages you
need, such as `AWSProviderStack`, `KubernetesProviderStack`, and
`HelmProviderStack`. Those provider XRs can set
`spec.nodePool.enabled: true` to use this stack's Crossplane NodePool, whose
default name remains `hops-crossplane`. Provider runtimes inherit the
CrossplaneStack NodePool placement rather than creating their own pools.

## Development

```bash
make render          # Render all examples
make validate        # Validate rendered output
make test            # Run KCL unit tests
make render:minimal  # Render single example
```
