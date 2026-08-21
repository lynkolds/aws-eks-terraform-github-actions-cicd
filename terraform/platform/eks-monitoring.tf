# ------------------------------------------------------------
# SNS topic for EKS monitoring notifications
# ------------------------------------------------------------

resource "aws_sns_topic" "eks_alerts" {
  name         = "${local.name_prefix}-eks-alerts"
  display_name = "${local.name_prefix} EKS alerts"

  tags = {
    Name = "${local.name_prefix}-eks-alerts"
  }
}


# ------------------------------------------------------------
# Email subscription
#
# AWS sends a confirmation email after creation. Notifications
# are not delivered until the subscription is confirmed.
# ------------------------------------------------------------

resource "aws_sns_topic_subscription" "eks_alert_email" {
  topic_arn = aws_sns_topic.eks_alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email
}


# ------------------------------------------------------------
# Alarm when one or more EKS worker nodes report a failed state
# ------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "eks_failed_nodes" {
  alarm_name        = "${local.name_prefix}-eks-failed-nodes"
  alarm_description = "One or more EKS worker nodes are reporting a failed condition."

  namespace   = "ContainerInsights"
  metric_name = "cluster_failed_node_count"

  dimensions = {
    ClusterName = local.eks_cluster_name
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1
  statistic           = "Maximum"

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.eks_alerts.arn]
  ok_actions    = [aws_sns_topic.eks_alerts.arn]

  depends_on = [
    aws_eks_addon.cloudwatch_observability
  ]

  tags = {
    Name = "${local.name_prefix}-eks-failed-nodes"
  }
}


# ------------------------------------------------------------
# Alarm when the total available worker-node count falls below
# the minimum expected count.
# ------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "eks_low_node_count" {
  alarm_name        = "${local.name_prefix}-eks-low-node-count"
  alarm_description = "The EKS cluster has fewer worker nodes than the configured minimum."

  namespace   = "ContainerInsights"
  metric_name = "cluster_node_count"

  dimensions = {
    ClusterName = local.eks_cluster_name
  }

  comparison_operator = "LessThanThreshold"
  threshold           = var.minimum_healthy_eks_node_count

  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  statistic           = "Minimum"

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.eks_alerts.arn]
  ok_actions    = [aws_sns_topic.eks_alerts.arn]

  depends_on = [
    aws_eks_addon.cloudwatch_observability
  ]

  tags = {
    Name = "${local.name_prefix}-eks-low-node-count"
  }
}


# ------------------------------------------------------------
# Alarm when average cluster node CPU remains high
# ------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "eks_high_node_cpu" {
  alarm_name        = "${local.name_prefix}-eks-high-node-cpu"
  alarm_description = "Average EKS node CPU utilization is above the configured threshold."

  namespace   = "ContainerInsights"
  metric_name = "node_cpu_utilization"

  dimensions = {
    ClusterName = local.eks_cluster_name
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.eks_node_cpu_alarm_threshold

  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  statistic           = "Average"

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.eks_alerts.arn]
  ok_actions    = [aws_sns_topic.eks_alerts.arn]

  depends_on = [
    aws_eks_addon.cloudwatch_observability
  ]

  tags = {
    Name = "${local.name_prefix}-eks-high-node-cpu"
  }
}


# ------------------------------------------------------------
# Alarm when average cluster node memory remains high
# ------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "eks_high_node_memory" {
  alarm_name        = "${local.name_prefix}-eks-high-node-memory"
  alarm_description = "Average EKS node memory utilization is above the configured threshold."

  namespace   = "ContainerInsights"
  metric_name = "node_memory_utilization"

  dimensions = {
    ClusterName = local.eks_cluster_name
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.eks_node_memory_alarm_threshold

  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  statistic           = "Average"

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.eks_alerts.arn]
  ok_actions    = [aws_sns_topic.eks_alerts.arn]

  depends_on = [
    aws_eks_addon.cloudwatch_observability
  ]

  tags = {
    Name = "${local.name_prefix}-eks-high-node-memory"
  }
}


# ------------------------------------------------------------
# Alarm when average node filesystem utilization remains high
# ------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "eks_high_node_filesystem" {
  alarm_name        = "${local.name_prefix}-eks-high-node-filesystem"
  alarm_description = "Average EKS node filesystem utilization is above the configured threshold."

  namespace   = "ContainerInsights"
  metric_name = "node_filesystem_utilization"

  dimensions = {
    ClusterName = local.eks_cluster_name
  }

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.eks_node_filesystem_alarm_threshold

  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2
  statistic           = "Average"

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.eks_alerts.arn]
  ok_actions    = [aws_sns_topic.eks_alerts.arn]

  depends_on = [
    aws_eks_addon.cloudwatch_observability
  ]

  tags = {
    Name = "${local.name_prefix}-eks-high-node-filesystem"
  }
}