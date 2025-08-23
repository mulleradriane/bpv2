resource "aws_iam_policy" "this" {
  name        = var.legacy_name != null ? var.legacy_name : "${var.product}-policy"
  path        = "/"
  description = "Policy for ${var.product} API Gateway users"
  policy      = var.policy
}

resource "aws_iam_policy_attachment" "this" {
  name       = "${var.product}-attachment"
  policy_arn = aws_iam_policy.this.arn
  groups     = var.groups_to_attachment
}