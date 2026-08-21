# ------------------------------------------------------------
# CloudWatch Observability Pod Identity trust policy
# ------------------------------------------------------------

data "aws_iam_policy_document" "cloudwatch_observability_assume_role" {
  statement {
    sid    = "AllowEksPodIdentity"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}


# ------------------------------------------------------------
# IAM role used by the CloudWatch agent
# ------------------------------------------------------------

resource "aws_iam_role" "cloudwatch_observability" {
  name               = "${local.name_prefix}-cloudwatch-observability-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_observability_assume_role.json

  tags = {
    Name = "${local.name_prefix}-cloudwatch-observability-role"
  }
}


# ------------------------------------------------------------
# AWS-managed permissions required by the CloudWatch agent
# ------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "cloudwatch_observability" {
  role       = aws_iam_role.cloudwatch_observability.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


# ------------------------------------------------------------
# Associate the IAM role with the CloudWatch agent service
# account through EKS Pod Identity.
#
# The service account is created by the EKS add-on.
# ------------------------------------------------------------

resource "aws_eks_pod_identity_association" "cloudwatch_observability" {
  cluster_name    = local.eks_cluster_name
  namespace       = "amazon-cloudwatch"
  service_account = "cloudwatch-agent"
  role_arn        = aws_iam_role.cloudwatch_observability.arn

  tags = {
    Name = "${local.name_prefix}-cloudwatch-observability"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudwatch_observability
  ]
}


# ------------------------------------------------------------
# Install the Amazon CloudWatch Observability EKS add-on
# with OTel Container Insights enabled.
# ------------------------------------------------------------

resource "aws_eks_addon" "cloudwatch_observability" {
  cluster_name  = local.eks_cluster_name
  addon_name    = "amazon-cloudwatch-observability"
  addon_version = var.cloudwatch_observability_addon_version

  configuration_values = jsonencode({
    otelContainerInsights = {
      enabled = true
    }
  })

  depends_on = [
    aws_eks_pod_identity_association.cloudwatch_observability
  ]

  tags = {
    Name = "${local.name_prefix}-cloudwatch-observability"
  }
}