output "application_pod_role_arn" {
  description = "IAM role used by the application Pods."
  value       = aws_iam_role.application_pod.arn
}

output "load_balancer_controller_role_arn" {
  description = "IAM role used by the AWS Load Balancer Controller."
  value       = aws_iam_role.load_balancer_controller.arn
}

output "application_namespace" {
  description = "Kubernetes namespace expected by the application."
  value       = var.application_namespace
}

output "application_service_account" {
  description = "Kubernetes service-account name expected by the application."
  value       = var.application_service_account
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster read from the EKS Terraform state."
  value       = local.eks_cluster_name
}

output "external_dns_role_arn" {
  description = "ARN of the IAM role used by ExternalDNS through EKS Pod Identity."
  value       = aws_iam_role.external_dns.arn
}

output "external_dns_namespace" {
  description = "Kubernetes namespace containing ExternalDNS."
  value       = var.external_dns_namespace
}

output "external_dns_service_account" {
  description = "Kubernetes service account used by ExternalDNS."
  value       = var.external_dns_service_account
}

output "external_dns_txt_owner_id" {
  description = "TXT registry owner identifier used by ExternalDNS."
  value       = local.external_dns_txt_owner_id
}

output "external_dns_managed_domain" {
  description = "Domain name that ExternalDNS is allowed to manage."
  value       = local.normalized_hosted_zone_name
}

output "external_dns_hosted_zone_id" {
  description = "Route 53 hosted-zone ID that ExternalDNS is allowed to modify."
  value       = local.normalized_hosted_zone_id
}

output "eks_alerts_sns_topic_arn" {
  description = "ARN of the SNS topic used by EKS CloudWatch alarms."
  value       = aws_sns_topic.eks_alerts.arn
}

output "eks_alert_email_subscription_arn" {
  description = "ARN or pending-confirmation identifier of the EKS email subscription."
  value       = aws_sns_topic_subscription.eks_alert_email.arn
}

output "cloudwatch_observability_role_arn" {
  description = "IAM role used by the CloudWatch Observability EKS add-on."
  value       = aws_iam_role.cloudwatch_observability.arn
}

output "cloudwatch_observability_addon_version" {
  description = "Installed CloudWatch Observability EKS add-on version."
  value       = aws_eks_addon.cloudwatch_observability.addon_version
}