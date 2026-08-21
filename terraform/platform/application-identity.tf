# Trust policy used by IAM roles assumed through EKS Pod Identity.
data "aws_iam_policy_document" "pod_identity_trust" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type = "Service"

      identifiers = [
        "pods.eks.amazonaws.com"
      ]
    }
  }
}


# Allows the application Pod to read only its own Secrets Manager secret.
resource "aws_iam_policy" "application_secret_access" {
  name = "${local.name_prefix}-application-secret-access"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadApplicationSecret"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]

        Resource = local.application_secret_arn
      }
    ]
  })
}


resource "aws_iam_role" "application_pod" {
  name = "${local.name_prefix}-application-pod-role"

  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = {
    Name = "${local.name_prefix}-application-pod-role"
  }
}


resource "aws_iam_role_policy_attachment" "application_secret_access" {
  role       = aws_iam_role.application_pod.name
  policy_arn = aws_iam_policy.application_secret_access.arn
}


# Connects the Kubernetes service account to the IAM role.
#
# The namespace and service account can be created later by the
# Kubernetes application workflow.
resource "aws_eks_pod_identity_association" "application" {
  cluster_name    = local.eks_cluster_name
  namespace       = var.application_namespace
  service_account = var.application_service_account
  role_arn        = aws_iam_role.application_pod.arn

  depends_on = [
    aws_eks_addon.pod_identity_agent
  ]
}