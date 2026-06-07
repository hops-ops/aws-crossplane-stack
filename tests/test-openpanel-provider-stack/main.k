import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_composition = "apis/openpanelproviderstacks/composition.yaml"
_xrd = "apis/openpanelproviderstacks/definition.yaml"

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
                kind = "OpenPanelProviderStack"
                metadata.name = "openpanel"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "drc-openpanel"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1beta1"
                        kind = "DeploymentRuntimeConfig"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "provider-openpanel"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Provider"
                        metadata.name = "provider-openpanel"
                        spec = {
                            package = "ghcr.io/hops-ops/provider-openpanel:v1.1.1"
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
                kind = "OpenPanelProviderStack"
                metadata.name = "openpanel"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                    secretName = "openpanel-creds"
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "providerconfig-openpanel"
                    spec.forProvider.manifest = {
                        apiVersion = "openpanel.m.crossplane.io/v1beta1"
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
                kind = "OpenPanelProviderStack"
                metadata.name = "openpanel"
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
                    metadata.name = "drc-openpanel"
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
                kind = "OpenPanelProviderStack"
                metadata.name = "openpanel"
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
                    metadata.name = "drc-openpanel"
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
