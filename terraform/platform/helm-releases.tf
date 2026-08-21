# Installs the community Secrets Store CSI Driver.
resource "helm_release" "secrets_store_csi_driver" {
  name      = "secrets-store-csi-driver"
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      tokenRequests = [
        {
          audience = "sts.amazonaws.com"
        },
        {
          audience = "pods.eks.amazonaws.com"
        }
      ]
    })
  ]

  set = [
    {
      name  = "syncSecret.enabled"
      value = "true"
    },
    {
      name  = "enableSecretRotation"
      value = "true"
    }
  ]
}

# Installs the AWS Secrets and Configuration Provider.
resource "helm_release" "ascp" {
  name      = "secrets-store-csi-driver-provider-aws"
  namespace = "kube-system"

  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  # The Secrets Store CSI Driver is already installed and managed
  # by helm_release.secrets_store_csi_driver. Disable the bundled
  # driver in the ASCP chart to prevent Helm ownership conflicts.
  values = [
    yamlencode({
      "secrets-store-csi-driver" = {
        install = false
      }
    })
  ]

  depends_on = [
    helm_release.secrets_store_csi_driver,
    aws_eks_addon.pod_identity_agent
  ]
}

# Installs the AWS Load Balancer Controller.
resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  namespace = "kube-system"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  set = [
    {
      name  = "clusterName"
      value = local.eks_cluster_name
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = local.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_eks_pod_identity_association.load_balancer_controller
  ]
}


# ==========================================================
# CLUSTER AUTOSCALER HELM RELEASE
# ==========================================================

resource "helm_release" "cluster_autoscaler" {

  name = "cluster-autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"

  chart = "cluster-autoscaler"

  # Pin the Helm chart so Terraform does not silently
  # install a newer release.
  version = local.cluster_autoscaler_chart_version

  namespace = local.cluster_autoscaler_namespace

  create_namespace = false


  # --------------------------------------------------------
  # Helm deployment safety
  # --------------------------------------------------------

  atomic = true

  wait = true

  timeout = 600


  values = [
    yamlencode({

      # ----------------------------------------------------
      # AWS cloud provider
      # ----------------------------------------------------

      cloudProvider = "aws"

      awsRegion = var.aws_region


      # ----------------------------------------------------
      # Automatically discover the EKS managed node group's
      # underlying EC2 Auto Scaling Group.
      # ----------------------------------------------------

      autoDiscovery = {
        clusterName = local.eks_cluster_name
      }


      # ----------------------------------------------------
      # Cluster Autoscaler image
      #
      # The Cluster Autoscaler Kubernetes minor version
      # should match the EKS Kubernetes minor version.
      # ----------------------------------------------------

      image = {
        repository = "registry.k8s.io/autoscaling/cluster-autoscaler"
        tag        = local.cluster_autoscaler_image_tag
      }


      # ----------------------------------------------------
      # Kubernetes RBAC and ServiceAccount
      #
      # Helm creates the required ClusterRole,
      # ClusterRoleBinding, etc.
      #
      # Terraform already created the ServiceAccount.
      # ----------------------------------------------------

      rbac = {
        create = true

        serviceAccount = {
          create = false
          name   = local.cluster_autoscaler_service_account
        }
      }


      # ----------------------------------------------------
      # One Cluster Autoscaler replica is sufficient for
      # this project.
      # ----------------------------------------------------

      replicaCount = 1


      # ----------------------------------------------------
      # Prevent Cluster Autoscaler from voluntarily
      # evicting its own Pod during node scale-down.
      # ----------------------------------------------------

      deployment = {
        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict" = "false"
        }
      }


      # ----------------------------------------------------
      # Resource requests and limits
      #
      # Requests allow Kubernetes to reserve enough
      # resources for the Cluster Autoscaler Pod.
      # ----------------------------------------------------

      resources = {

        requests = {
          cpu    = "100m"
          memory = "300Mi"
        }

        limits = {
          cpu    = "200m"
          memory = "600Mi"
        }
      }
    })
  ]


  # --------------------------------------------------------
  # Do not start Cluster Autoscaler until:
  #
  # - ServiceAccount exists
  # - IAM role exists
  # - IAM permissions exist
  # - Pod Identity association exists
  # - Pod Identity Agent exists
  # --------------------------------------------------------

  depends_on = [
    aws_eks_pod_identity_association.cluster_autoscaler
  ]
}