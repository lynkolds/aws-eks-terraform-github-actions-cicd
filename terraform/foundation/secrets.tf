# Creates the Secrets Manager secret container.
#
# Terraform does not create the secret value in this resource.
# A later protected GitHub Actions workflow will populate the secret
# after the RDS endpoint is available.
resource "aws_secretsmanager_secret" "application" {
  name = "${var.project_name}/${var.environment}/application"

  description = "Application and database configuration for ${local.name_prefix}"

  recovery_window_in_days = var.secrets_recovery_window_days

  tags = {
    Name = "${local.name_prefix}-application-secret"
  }
}