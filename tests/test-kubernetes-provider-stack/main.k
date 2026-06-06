import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_composition = "apis/kubernetesproviderstacks/composition.yaml"
_xrd = "apis/kubernetesproviderstacks/definition.yaml"

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
                kind = "KubernetesProviderStack"
                metadata.name = "kubernetes"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "drc-kubernetes"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1beta1"
                        kind = "DeploymentRuntimeConfig"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "provider-kubernetes"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Provider"
                        metadata.name = "crossplane-contrib-provider-kubernetes"
                        spec = {
                            package = "xpkg.crossplane.io/crossplane-contrib/provider-kubernetes:v1.2.0"
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
                kind = "KubernetesProviderStack"
                metadata.name = "kubernetes"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "providerconfig-kubernetes"
                    spec.forProvider.manifest = {
                        apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
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
                kind = "KubernetesProviderStack"
                metadata.name = "kubernetes"
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
                    metadata.name = "drc-kubernetes"
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
                kind = "KubernetesProviderStack"
                metadata.name = "kubernetes"
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
                    metadata.name = "drc-kubernetes"
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

items = _items
