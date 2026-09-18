import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_composition = "apis/helmproviderstacks/composition.yaml"
_xrd = "apis/helmproviderstacks/definition.yaml"

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
                kind = "HelmProviderStack"
                metadata.name = "helm"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "drc-helm"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1beta1"
                        kind = "DeploymentRuntimeConfig"
                        spec.deploymentTemplate.spec.template.spec.serviceAccountName = "my-cluster-helm"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "sa-helm"
                    spec.forProvider.manifest = {
                        kind = "ServiceAccount"
                        metadata = {name = "my-cluster-helm", namespace = "crossplane-system"}
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "provider-helm"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Provider"
                        metadata.name = "crossplane-contrib-provider-helm"
                        spec = {
                            package = "xpkg.crossplane.io/crossplane-contrib/provider-helm:v1.4.0"
                            skipDependencyResolution = True
                        }
                    }
                }
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "renders-providerconfig"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "crossplane.hops.ops.com.ai/v1alpha1"
                kind = "HelmProviderStack"
                metadata.name = "helm"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "providerconfig-helm"
                    spec.forProvider.manifest = {
                        apiVersion = "helm.m.crossplane.io/v1beta1"
                        kind = "ProviderConfig"
                    }
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
                kind = "HelmProviderStack"
                metadata.name = "helm"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                    nodePool.enabled = True
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "drc-helm"
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

    metav1alpha1.CompositionTest {
        metadata.name = "explicit-scheduling-override"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "crossplane.hops.ops.com.ai/v1alpha1"
                kind = "HelmProviderStack"
                metadata.name = "helm"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                    scheduling = {
                        nodeSelector = {"example.com/workload" = "provider"}
                        tolerations = [
                            {key = "example.com/workload", operator = "Equal", value = "provider", effect = "NoSchedule"}
                        ]
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "drc-helm"
                    spec.forProvider.manifest.spec.deploymentTemplate.spec.template.spec = {
                        nodeSelector = {"example.com/workload" = "provider"}
                        tolerations = [
                            {key = "example.com/workload", operator = "Equal", value = "provider", effect = "NoSchedule"}
                        ]
                    }
                }
            ]
        }
    }
]

items = _items + [
    metav1alpha1.CompositionTest {
        metadata.name = "ecr-identity-uses-runtime-account-and-aws-config"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "crossplane.hops.ops.com.ai/v1alpha1"
                kind = "HelmProviderStack"
                metadata.name = "helm"
                spec = {
                    clusterName = "my-cluster"
                    crossplaneNamespace = "custom-crossplane"
                    aws = {
                        enabled = True
                        region = "us-east-2"
                        providerConfigRef = {name = "aws-admin", kind = "ClusterProviderConfig"}
                        ecrRepositoryArns = ["arn:aws:ecr:us-east-2:123456789012:repository/team/charts/*"]
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "helm-helm-ecr"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-2"
                        providerConfigRef = {name = "aws-admin", kind = "ClusterProviderConfig"}
                        serviceAccount = {name = "my-cluster-helm", namespace = "custom-crossplane"}
                    }
                }
            ]
        }
    }
    metav1alpha1.CompositionTest {
        metadata.name = "account-outlives-ready-provider"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "crossplane.hops.ops.com.ai/v1alpha1"
                kind = "HelmProviderStack"
                metadata.name = "helm"
                spec.clusterName = "my-cluster"
                metadata.namespace = "default"
            }
            observedResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata = {
                        name = name
                        namespace = "default"
                        annotations = {"crossplane.io/composition-resource-name" = name}
                    }
                    status.conditions = [{type = "Ready", status = "True"}]
                } for name in ["sa-helm", "provider-helm"]
            ]
            assertResources = [
                {
                    apiVersion = "protection.crossplane.io/v1beta1"
                    kind = "Usage"
                    metadata.name = "delete-provider-helm-before-sa-helm"
                    spec = {
                        of.resourceRef.name = "sa-helm"
                        by.resourceRef.name = "provider-helm"
                        replayDeletion = True
                    }
                }
            ]
        }
    }
]
