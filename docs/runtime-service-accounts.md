# Runtime service account ownership

Provider stacks manage their stable service accounts through Kubernetes Objects.
DeploymentRuntimeConfigs reference those accounts with
`deploymentTemplate.spec.template.spec.serviceAccountName`. This preserves the
names used by Pod Identity and Kubernetes RBAC while allowing multiple package
revisions, and the AWS family providers, to use the same account.

Functions use Crossplane's generated per-revision accounts; they have no
external bindings that require a stable account name.

Do not set `serviceAccountTemplate.metadata.name` for shared accounts. Crossplane
then tries to make each package revision their controller, and Kubernetes rejects
the competing controller owner references.

## Private ECR Helm charts

`HelmProviderStack.spec.aws` optionally enables EKS Pod Identity for the Helm
runtime. Set `enabled: true`, `region`, and `ecrRepositoryArns` to the private
chart repositories it may read. `aws.providerConfigRef` selects the AWS provider
configuration and defaults to the cluster name. No AWS identity is created when
this option is omitted or disabled.

The stack binds the role to its own stable runtime service account. Its policy
allows ECR token generation and read access only to the supplied repositories;
it does not grant repository creation, upstream import, or image publication.
This is separate from Crossplane package-manager authentication.

Application environments should create their own namespaced Helm
`ProviderConfig` with `credentials.source: InjectedIdentity`. The shared
Helm runtime's AWS access belongs to the provider stack.

Existing Helm pods must be recreated after the Pod Identity association is ready
to receive EKS credential injection.

## Migrating existing installations

Existing accounts can still carry an owner reference to a package revision from
the previous templates. After the new runtime configuration and ServiceAccount
Object have reconciled, inspect each affected account and remove only that
obsolete ProviderRevision controller reference. Preserve unrelated metadata and
any new owner references. Do not delete the account: existing RBAC and Pod
Identity associations refer to its stable name.

Verify all provider and function packages become Healthy before removing old
registry infrastructure or pruning inactive package revisions.
