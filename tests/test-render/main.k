import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_composition = "apis/crossplanestacks/composition.yaml"
_xrd = "apis/crossplanestacks/definition.yaml"

_items = [
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-crossplane-core"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "crossplane"
                    spec = {
                        forProvider = {
                            chart = {
                                name = "crossplane"
                                repository = "https://charts.crossplane.io/stable"
                                version = "2.2.0"
                            }
                            namespace = "crossplane-system"
                            values = {
                                metrics.enabled = True
                                serviceMonitor.enabled = True
                                resourcesCrossplane.requests = {cpu = "247m", memory = "1052Mi"}
                                resourcesRBACManager.requests = {cpu = "15m", memory = "100Mi"}
                            }
                        }
                        providerConfigRef = {
                            name = "my-cluster"
                            kind = "ProviderConfig"
                        }
                    }
                }
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "crossplane-helm-values-merge"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    install = {
                        values = {
                            replicas = 2
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "crossplane"
                    spec.forProvider.values = {
                        metrics.enabled = True
                        serviceMonitor.enabled = True
                        replicas = 2
                    }
                }
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "override-all-values-replaces-defaults"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    install = {
                        overrideAllValues = {
                            replicas = 1
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "crossplane"
                    spec.forProvider.values = {
                        replicas = 1
                    }
                }
            ]
        }
    }

    metav1alpha1.CompositionTest {
        metadata.name = "nodepool-enabled-renders-nodepool-and-schedules-core"
        spec = {
            compositionPath = _composition
            xrdPath = _xrd
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    nodePool = {
                        enabled = True
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha1"
                    kind = "Object"
                    metadata.name = "nodepool-crossplane"
                    spec.forProvider.manifest = {
                        apiVersion = "karpenter.sh/v1"
                        kind = "NodePool"
                        metadata.name = "hops-crossplane"
                        spec.template.spec.nodeClassRef = {
                            group = "eks.amazonaws.com"
                            kind = "NodeClass"
                            name = "hops-default"
                        }
                        spec.template.spec.requirements = [
                            {key = "karpenter.sh/capacity-type", operator = "In", values = ["spot"]}
                            {key = "eks.amazonaws.com/instance-category", operator = "In", values = ["c", "m", "r", "t"]}
                            {key = "eks.amazonaws.com/instance-generation", operator = "Gte", values = ["4"]}
                            {key = "kubernetes.io/os", operator = "In", values = ["linux"]}
                        ]
                        spec.disruption = {
                            consolidationPolicy = "WhenEmptyOrUnderutilized"
                            consolidateAfter = "30s"
                            budgets = [{nodes = "100%"}]
                        }
                    }
                }
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "crossplane"
                    spec.forProvider.values = {
                        nodeSelector = {
                            "workload-type" = "crossplane"
                        }
                        tolerations = [
                            {
                                key = "crossplane"
                                operator = "Equal"
                                value = "true"
                                effect = "NoSchedule"
                            }
                        ]
                        rbacManager = {
                            nodeSelector = {
                                "workload-type" = "crossplane"
                            }
                            tolerations = [
                                {
                                    key = "crossplane"
                                    operator = "Equal"
                                    value = "true"
                                    effect = "NoSchedule"
                                }
                            ]
                        }
                    }
                }
                {
                    apiVersion = "protection.crossplane.io/v1beta1"
                    kind = "Usage"
                    metadata.name = "delete-crossplane-before-nodepool"
                    spec.replayDeletion = True
                }
            ]
        }
    }
]

items = _items
