# Registers GitHub Actions as a trusted external OIDC identity provider
# inside this AWS account.
#
# This does NOT give GitHub any AWS permissions by itself.
# It only allows AWS to recognize and validate tokens issued by GitHub.

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# This is a Terraform data source, not an AWS resource.
# It generates a policy document describing who may assume the Github OIDC role.
# Modify repository and branch to match your GitHub repository and branch.

data "aws_iam_policy_document" "github_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
                "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}:environment:${var.github_environment_name}"
      ]
    }
  }
}

# Creates the IAM role that can be assumed by GitHub Actions after AWS validates
# the GitHub OIDC token.
#
# References the trust policy document above to define the role's trust relationship.

resource "aws_iam_role" "github_deployment" {
  name = "${var.project_name}-${var.environment}-github-deployment-role"
 
  assume_role_policy = data.aws_iam_policy_document.github_trust.json

  # Limits the maximum duration of each temporary role session.
  max_session_duration = 3600

  tags = {
    Name        = "${var.project_name}-${var.environment}-github-deployment-role"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "GitHub Actions deployment"
  }
}


# Attaches AWS's managed AdministratorAccess permission policy
# to the GitHub Actions deployment role.

resource "aws_iam_role_policy_attachment" "github_deployment_admin" {
  role       = aws_iam_role.github_deployment.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
