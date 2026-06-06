import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_composition = "apis/awsproviderstacks/composition.yaml"
_xrd = "apis/awsproviderstacks/definition.yaml"

_items = [
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-provider"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "crossplane.hops.ops.com.ai/v1alpha1"
                kind = "AWSProviderStack"
                metadata.name = "aws"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                    aws.region = "us-east-1"
                    providers = {iam = {}, s3 = {}}
                }
            }
            assertResources = [
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "pod-identity"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                        serviceAccount = {name = "my-cluster-crossplane-aws", namespace = "crossplane-system"}
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "provider-family-aws"
                    spec.forProvider.manifest.spec = {
                        package = "xpkg.crossplane.io/crossplane-contrib/provider-family-aws:v2.5.0"
                        skipDependencyResolution = True
                        runtimeConfigRef.name = "my-cluster-aws"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "provider-aws-iam"
                    spec.forProvider.manifest.spec.package = "xpkg.crossplane.io/crossplane-contrib/provider-aws-iam:v2.5.0"
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "provider-aws-s3"
                    spec.forProvider.manifest.spec.package = "xpkg.crossplane.io/crossplane-contrib/provider-aws-s3:v2.5.0"
                }
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "nodepool-schedules-runtime"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "crossplane.hops.ops.com.ai/v1alpha1"
                kind = "AWSProviderStack"
                metadata.name = "aws"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                    aws.region = "us-east-1"
                    nodePool.enabled = True
                    providers = {iam = {}}
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "drc-aws"
                    spec.forProvider.manifest.spec.deploymentTemplate.spec.template.spec = {
                        nodeSelector = {"workload-type" = "crossplane"}
                        tolerations = [
                            {key = "crossplane", operator = "Equal", value = "true", effect = "NoSchedule"}
                        ]
                    }
                }
            ]
        }
    }
]

items = _items
