# ------------------------------------------------------------
# ExternalDNS Pod Identity trust policy
# ------------------------------------------------------------

data "aws_iam_policy_document" "external_dns_assume_role" {
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
# ExternalDNS IAM role
# ------------------------------------------------------------

resource "aws_iam_role" "external_dns" {
  name               = "${local.name_prefix}-external-dns-role"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role.json

  tags = {
    Name = "${local.name_prefix}-external-dns-role"
  }
}


# ------------------------------------------------------------
# Least-privilege Route 53 policy
#
# Record-changing permissions are restricted to the exact
# hosted zone supplied through hosted_zone_id.
# ------------------------------------------------------------

data "aws_iam_policy_document" "external_dns" {
  statement {
    sid    = "ManageApplicationHostedZone"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResources"
    ]

    resources = [
      "arn:aws:route53:::hostedzone/${local.normalized_hosted_zone_id}"
    ]
  }

  statement {
    sid    = "ListHostedZones"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones"
    ]

    resources = ["*"]
  }
}


# ------------------------------------------------------------
# Customer-managed IAM policy
# ------------------------------------------------------------

resource "aws_iam_policy" "external_dns" {
  name        = "${local.name_prefix}-external-dns-policy"
  description = "Allows ExternalDNS to manage records in the application Route 53 hosted zone."
  policy      = data.aws_iam_policy_document.external_dns.json

  tags = {
    Name = "${local.name_prefix}-external-dns-policy"
  }
}


# ------------------------------------------------------------
# Attach the Route 53 policy to the ExternalDNS role
# ------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}


# ------------------------------------------------------------
# Associate the IAM role with the ExternalDNS service account
# through EKS Pod Identity.
# ------------------------------------------------------------

resource "aws_eks_pod_identity_association" "external_dns" {
  cluster_name    = local.eks_cluster_name
  namespace       = var.external_dns_namespace
  service_account = var.external_dns_service_account
  role_arn        = aws_iam_role.external_dns.arn

  tags = {
    Name = "${local.name_prefix}-external-dns"
  }
}


# ------------------------------------------------------------
# Install ExternalDNS using the official Helm chart
# ------------------------------------------------------------

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.external_dns_chart_version

  namespace        = var.external_dns_namespace
  create_namespace = true

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      provider = {
        name = "aws"
      }

      # The application uses an ALB-backed Ingress.
      sources = [
        "ingress"
      ]

      # Safer initial setting:
      # records may be created and updated, but not deleted.
      policy = "upsert-only"

      registry   = "txt"
      txtOwnerId = local.external_dns_txt_owner_id

      # Limit discovered DNS names to the application domain.
      domainFilters = [
        local.normalized_hosted_zone_name
      ]

      serviceAccount = {
        create = true
        name   = var.external_dns_service_account
      }

      # Reduce unnecessary Route 53 polling.
      interval = "5m"

      logFormat = "json"

      extraArgs = {
        # Restrict ExternalDNS to the exact Route 53 hosted zone.
        "zone-id-filter" = [
          local.normalized_hosted_zone_id
        ]

        # This project exposes a public HTTPS application.
        "aws-zone-type" = "public"

        # React to Kubernetes resource changes.
        events = true

        # Cache the hosted-zone list to reduce Route 53 API calls.
        "aws-zones-cache-duration" = "1h"
      }
    })
  ]

  depends_on = [
    aws_iam_role_policy_attachment.external_dns,
    aws_eks_pod_identity_association.external_dns
  ]
}