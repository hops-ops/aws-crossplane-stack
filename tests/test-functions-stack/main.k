import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_composition = "apis/functionsstacks/composition.yaml"
_xrd = "apis/functionsstacks/definition.yaml"

_items = [
    # Default (no functions specified) installs function-auto-ready with a DRC.
    metav1alpha1.CompositionTest {
        metadata.name = "default-installs-auto-ready"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "crossplane.hops.ops.com.ai/v1alpha1"
                kind = "FunctionsStack"
                metadata.name = "functions"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "drc-auto-ready"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1beta1"
                        kind = "DeploymentRuntimeConfig"
                        metadata.name = "crossplane-contrib-function-auto-ready"
                        spec.deploymentTemplate.spec.template.spec.containers = [
                            {
                                name = "package-runtime"
                                resources.requests = {cpu = "15m", memory = "100Mi"}
                            }
                        ]
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "function-auto-ready"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Function"
                        metadata.name = "crossplane-contrib-function-auto-ready"
                        spec = {
                            package = "xpkg.crossplane.io/crossplane-contrib/function-auto-ready:v0.7.0"
                            skipDependencyResolution = True
                            runtimeConfigRef.name = "crossplane-contrib-function-auto-ready"
                        }
                    }
                }
            ]
        }
    }

    # nodePool.enabled schedules the function runtime onto the Crossplane NodePool.
    metav1alpha1.CompositionTest {
        metadata.name = "nodepool-schedules-runtime"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "crossplane.hops.ops.com.ai/v1alpha1"
                kind = "FunctionsStack"
                metadata.name = "functions"
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
                    metadata.name = "drc-auto-ready"
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

    # A multi-function map renders one Function + DRC per entry, with per-function resources.
    metav1alpha1.CompositionTest {
        metadata.name = "multi-function-with-resources"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "crossplane.hops.ops.com.ai/v1alpha1"
                kind = "FunctionsStack"
                metadata.name = "functions"
                spec = {
                    clusterName = "my-cluster"
                    kubernetesProviderConfigRef.name = "my-cluster"
                    functions = {
                        autoReady = {
                            package = "xpkg.crossplane.io/crossplane-contrib/function-auto-ready"
                            version = "v0.6.5"
                        }
                        patchAndTransform = {
                            package = "xpkg.crossplane.io/crossplane-contrib/function-patch-and-transform"
                            version = "v0.9.0"
                            runtimeConfig = {
                                requestsCpu = "50m"
                                requestsMemory = "256Mi"
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "function-patch-and-transform"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Function"
                        metadata.name = "crossplane-contrib-function-patch-and-transform"
                        spec = {
                            package = "xpkg.crossplane.io/crossplane-contrib/function-patch-and-transform:v0.9.0"
                            runtimeConfigRef.name = "crossplane-contrib-function-patch-and-transform"
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "drc-patch-and-transform"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1beta1"
                        kind = "DeploymentRuntimeConfig"
                        metadata.name = "crossplane-contrib-function-patch-and-transform"
                        spec.deploymentTemplate.spec.template.spec.containers = [
                            {
                                name = "package-runtime"
                                resources.requests = {cpu = "50m", memory = "256Mi"}
                            }
                        ]
                    }
                }
            ]
        }
    }
]

items = _items
