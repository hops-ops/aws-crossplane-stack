# aws-crossplane-stack

Installs Crossplane via Helm and configures AWS (IRSA), Kubernetes, Helm, and GitHub providers with toggle flags.

## Overview

Single unified XRD that replaces multiple separate configurations for Crossplane + providers. Creates:

1. **Crossplane Helm Release** — Crossplane from the stable chart repo
2. **AWS Provider** — IRSA IAM Role + ProviderConfig + DRC + provider-family-aws + sub-providers
3. **Kubernetes Provider** — ProviderConfig (InjectedIdentity) + DRC + provider-kubernetes
4. **Helm Provider** — ProviderConfig (InjectedIdentity) + DRC + provider-helm
5. **GitHub Provider** (optional) — ProviderConfig + DRC + provider-upjet-github + ExternalSecret
6. **Functions** — function-auto-ready

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
  aws:
    accountId: "123456789012"
    oidc: oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE123
    region: us-east-1
```

### With GitHub provider and sub-providers

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
  tags:
    environment: production
  aws:
    accountId: "123456789012"
    oidc: oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE123
    region: us-east-1
  providers:
    aws:
      providers:
        iam: {}
        s3: {}
        ec2: {}
    github:
      enabled: true
      githubOrg: my-org
      secretName: github-provider-token
```

## Development

```bash
make render          # Render all examples
make validate        # Validate rendered output
make test            # Run KCL unit tests
make render:minimal  # Render single example
```
