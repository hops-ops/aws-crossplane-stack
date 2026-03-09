import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# Unit tests for aws CrossplaneStack XRD
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: Minimal input renders Crossplane Helm release and default providers
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-crossplane-and-providers"
        spec = {
            compositionPath = "apis/crossplanestacks/composition.yaml"
            xrdPath = "apis/crossplanestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
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
                        }
                        providerConfigRef.name = "my-cluster"
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "crossplane-pod-identity"
                    spec = {
                        clusterName = "my-cluster"
                        region = "us-east-1"
                        serviceAccount = {
                            name = "my-cluster-crossplane-aws"
                            namespace = "crossplane-system"
                        }
                        managedPolicyArns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-providerconfig-aws"
                    spec.forProvider.manifest = {
                        apiVersion = "aws.upbound.io/v1beta1"
                        kind = "ProviderConfig"
                        metadata.name = "my-cluster"
                        spec.credentials.source = "PodIdentity"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-provider-family-aws"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Provider"
                        metadata.name = "crossplane-contrib-provider-family-aws"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-providerconfig-kubernetes"
                    spec.forProvider.manifest = {
                        apiVersion = "kubernetes.crossplane.io/v1alpha1"
                        kind = "ProviderConfig"
                        metadata.name = "my-cluster"
                        spec.credentials.source = "InjectedIdentity"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-provider-kubernetes"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Provider"
                        metadata.name = "crossplane-contrib-provider-kubernetes"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-providerconfig-helm"
                    spec.forProvider.manifest = {
                        apiVersion = "helm.crossplane.io/v1beta1"
                        kind = "ProviderConfig"
                        metadata.name = "my-cluster"
                        spec.credentials.source = "InjectedIdentity"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-provider-helm"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Provider"
                        metadata.name = "crossplane-contrib-provider-helm"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-function-auto-ready"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Function"
                        metadata.name = "crossplane-contrib-function-auto-ready"
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 2: GitHub provider disabled by default
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "github-disabled-by-default"
        spec = {
            compositionPath = "apis/crossplanestacks/composition.yaml"
            xrdPath = "apis/crossplanestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "crossplane"
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "crossplane-pod-identity"
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-provider-family-aws"
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-provider-kubernetes"
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-provider-helm"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 3: GitHub provider enabled renders all GitHub resources
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "github-enabled-renders-resources"
        spec = {
            compositionPath = "apis/crossplanestacks/composition.yaml"
            xrdPath = "apis/crossplanestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    providers = {
                        github = {
                            enabled = True
                            githubOrg = "my-org"
                            secretName = "github-token"
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-providerconfig-github"
                    spec.forProvider.manifest = {
                        apiVersion = "github.upbound.io/v1beta1"
                        kind = "ProviderConfig"
                        metadata.name = "github"
                        spec.credentials = {
                            source = "Secret"
                            secretRef = {
                                name = "github-token"
                                namespace = "crossplane-system"
                                key = "credentials"
                            }
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-drc-github"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1beta1"
                        kind = "DeploymentRuntimeConfig"
                        metadata.name = "github-github"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-provider-github"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Provider"
                        metadata.name = "crossplane-contrib-provider-upjet-github"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-externalsecret-github"
                    spec.forProvider.manifest = {
                        apiVersion = "external-secrets.io/v1beta1"
                        kind = "ExternalSecret"
                        metadata = {
                            name = "github-token"
                            namespace = "crossplane-system"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 4: AWS sub-providers render correctly
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "aws-sub-providers-render"
        spec = {
            compositionPath = "apis/crossplanestacks/composition.yaml"
            xrdPath = "apis/crossplanestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    providers = {
                        aws = {
                            providers = {
                                iam = {}
                                s3 = {}
                            }
                        }
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-provider-aws-iam"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Provider"
                        metadata.name = "crossplane-contrib-provider-aws-iam"
                        spec.package = "xpkg.crossplane.io/crossplane-contrib/provider-aws-iam"
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-provider-aws-s3"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1"
                        kind = "Provider"
                        metadata.name = "crossplane-contrib-provider-aws-s3"
                        spec.package = "xpkg.crossplane.io/crossplane-contrib/provider-aws-s3"
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 5: Custom Crossplane Helm values merge with defaults
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "crossplane-helm-values-merge"
        spec = {
            compositionPath = "apis/crossplanestacks/composition.yaml"
            xrdPath = "apis/crossplanestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
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

    # ==========================================================================
    # Test 6: PodIdentity renders with permissionsBoundary and rolePrefix
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "pod-identity-with-boundary-and-prefix"
        spec = {
            compositionPath = "apis/crossplanestacks/composition.yaml"
            xrdPath = "apis/crossplanestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "prod-cluster"
                    aws = {
                        region = "eu-west-1"
                        permissionsBoundary = "arn:aws:iam::999888777666:policy/boundary"
                        rolePrefix = "prod-"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "crossplane-pod-identity"
                    spec = {
                        clusterName = "prod-cluster"
                        region = "eu-west-1"
                        permissionsBoundaryArn = "arn:aws:iam::999888777666:policy/boundary"
                        rolePrefix = "prod-"
                        serviceAccount = {
                            name = "prod-cluster-crossplane-aws"
                            namespace = "crossplane-system"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 7: Labels and tags propagate to resources
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "labels-and-tags-propagate"
        spec = {
            compositionPath = "apis/crossplanestacks/composition.yaml"
            xrdPath = "apis/crossplanestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    labels = {
                        team = "platform"
                    }
                    tags = {
                        environment = "production"
                    }
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "crossplane"
                    metadata.labels = {
                        team = "platform"
                        "hops.ops.com.ai/managed" = "true"
                        "hops.ops.com.ai/crossplanestack" = "crossplane"
                    }
                }
                {
                    apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                    kind = "PodIdentity"
                    metadata.name = "crossplane-pod-identity"
                    metadata.labels = {
                        team = "platform"
                        "hops.ops.com.ai/managed" = "true"
                        "hops.ops.com.ai/crossplanestack" = "crossplane"
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 8: NodePool enabled renders NodePool and DRC tolerations
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "nodepool-enabled-renders-resources"
        spec = {
            compositionPath = "apis/crossplanestacks/composition.yaml"
            xrdPath = "apis/crossplanestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                    nodePool = {
                        enabled = True
                        nodeClassName = "default"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-nodepool-crossplane"
                    spec.forProvider.manifest = {
                        apiVersion = "karpenter.sh/v1"
                        kind = "NodePool"
                        metadata.name = "my-cluster-crossplane"
                        spec = {
                            template = {
                                metadata.labels = {
                                    "workload-type" = "crossplane"
                                }
                                spec = {
                                    nodeClassRef = {
                                        group = "eks.amazonaws.com"
                                        kind = "NodeClass"
                                        name = "default"
                                    }
                                    taints = [
                                        {
                                            key = "crossplane"
                                            value = "true"
                                            effect = "NoSchedule"
                                        }
                                    ]
                                }
                            }
                        }
                    }
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-drc-aws"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1beta1"
                        kind = "DeploymentRuntimeConfig"
                        spec.deploymentTemplate.spec.template.spec = {
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
            ]
        }
    }

    # ==========================================================================
    # Test 9: NodePool disabled does not render NodePool or tolerations
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "nodepool-disabled-no-resources"
        spec = {
            compositionPath = "apis/crossplanestacks/composition.yaml"
            xrdPath = "apis/crossplanestacks/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "aws.hops.ops.com.ai/v1alpha1"
                kind = "CrossplaneStack"
                metadata.name = "crossplane"
                spec = {
                    clusterName = "my-cluster"
                    aws = {
                        region = "us-east-1"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "crossplane"
                }
                {
                    apiVersion = "kubernetes.m.crossplane.io/v1alpha2"
                    kind = "Object"
                    metadata.name = "crossplane-drc-aws"
                    spec.forProvider.manifest = {
                        apiVersion = "pkg.crossplane.io/v1beta1"
                        kind = "DeploymentRuntimeConfig"
                    }
                }
            ]
        }
    }
]

items = _items
