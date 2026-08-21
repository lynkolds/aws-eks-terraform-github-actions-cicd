resource "aws_iam_policy" "load_balancer_controller" {
  name = "${local.name_prefix}-load-balancer-controller-policy"

  policy = file(
    "${path.module}/aws-load-balancer-controller-policy.json"
  )
}


resource "aws_iam_role" "load_balancer_controller" {
  name = "${local.name_prefix}-load-balancer-controller-role"

  assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json

  tags = {
    Name = "${local.name_prefix}-load-balancer-controller-role"
  }
}


resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}


resource "aws_eks_pod_identity_association" "load_balancer_controller" {
  cluster_name    = local.eks_cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.load_balancer_controller.arn

  depends_on = [
    aws_eks_addon.pod_identity_agent
  ]
}