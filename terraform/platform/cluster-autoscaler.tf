# ==========================================================
# CLUSTER AUTOSCALER
# ==========================================================
#
# Cluster Autoscaler automatically adjusts the desired size
# of the EKS managed node group's underlying EC2 Auto Scaling
# Group when Pods cannot be scheduled because the cluster
# does not have enough compute capacity.
#
# AWS authentication is provided through EKS Pod Identity.
# ==========================================================

# ==========================================================
# IAM TRUST POLICY
# ==========================================================
#
# Allows EKS Pod Identity to provide temporary AWS
# credentials to the Cluster Autoscaler Pod.
#
# The trust relationship is restricted to:
#
# Namespace:
#   kube-system
#
# ServiceAccount:
#   cluster-autoscaler
#
# This prevents other Kubernetes service accounts from
# assuming the Cluster Autoscaler IAM role.
# ==========================================================

data "aws_iam_policy_document" "cluster_autoscaler_assume_role" {

  statement {
    sid    = "AllowEksPodIdentity"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-namespace"

      values = [
        local.cluster_autoscaler_namespace
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/kubernetes-service-account"

      values = [
        local.cluster_autoscaler_service_account
      ]
    }
  }
}


# ==========================================================
# CLUSTER AUTOSCALER IAM ROLE
# ==========================================================

resource "aws_iam_role" "cluster_autoscaler" {

  name = "${var.project_name}-${var.environment}-cluster-autoscaler-role"

  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster-autoscaler-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


# ==========================================================
# CLUSTER AUTOSCALER IAM PERMISSIONS
# ==========================================================
#
# Cluster Autoscaler needs:
#
# 1. Write permissions
#    - Change desired ASG capacity
#    - Terminate nodes during scale-down
#
# 2. Read permissions
#    - Discover Auto Scaling Groups
#    - Inspect instances and launch templates
#    - Inspect EKS managed node groups
#
# Write permissions are restricted to Auto Scaling Groups
# belonging to this EKS cluster.
# ==========================================================

data "aws_iam_policy_document" "cluster_autoscaler" {

  # --------------------------------------------------------
  # Modify desired capacity for this cluster only
  # --------------------------------------------------------

  statement {
    sid    = "AllowClusterAutoscalerScaling"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/enabled"

      values = [
        "true"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/${local.eks_cluster_name}"

      values = [
        "owned"
      ]
    }
  }


  # --------------------------------------------------------
  # Read-only discovery permissions
  # --------------------------------------------------------

  statement {
    sid    = "AllowClusterAutoscalerDiscovery"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]

    resources = [
      "*"
    ]
  }
}


# ==========================================================
# ATTACH IAM POLICY TO CLUSTER AUTOSCALER ROLE
# ==========================================================
#
# This project uses an inline IAM policy because the
# permissions are used only by this Cluster Autoscaler role.
# ==========================================================

resource "aws_iam_role_policy" "cluster_autoscaler" {

  name = "${var.project_name}-${var.environment}-cluster-autoscaler-policy"

  role = aws_iam_role.cluster_autoscaler.id

  policy = data.aws_iam_policy_document.cluster_autoscaler.json
}


# ==========================================================
# KUBERNETES SERVICE ACCOUNT
# ==========================================================
#
# Terraform creates the ServiceAccount explicitly instead
# of allowing Helm to create it.
#
# This gives Terraform a clear dependency chain:
#
# ServiceAccount
#       ↓
# Pod Identity association
#       ↓
# Cluster Autoscaler Helm release
# ==========================================================

resource "kubernetes_service_account_v1" "cluster_autoscaler" {

  metadata {
    name      = local.cluster_autoscaler_service_account
    namespace = local.cluster_autoscaler_namespace

    labels = {
      "app.kubernetes.io/name"       = "cluster-autoscaler"
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }
}


# ==========================================================
# EKS POD IDENTITY ASSOCIATION
# ==========================================================
#
# Kubernetes ServiceAccount
#       ↓
# EKS Pod Identity
#       ↓
# Cluster Autoscaler IAM Role
#       ↓
# EC2 Auto Scaling API
#
# No IRSA role annotation is required.
# ==========================================================

resource "aws_eks_pod_identity_association" "cluster_autoscaler" {

  cluster_name = local.eks_cluster_name

  namespace = local.cluster_autoscaler_namespace

  service_account = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name

  role_arn = aws_iam_role.cluster_autoscaler.arn

  depends_on = [
    aws_iam_role_policy.cluster_autoscaler,
    aws_eks_addon.pod_identity_agent
  ]
}

