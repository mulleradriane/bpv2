resource "aws_iam_group" "this" {
  name = var.legacy_name != null ? var.legacy_name : "${var.team}-${var.role}-group"
  path = "/"
}

resource "aws_iam_group_membership" "this" {
  name  = "${var.team}-${var.role}-membership"
  users = var.users_to_attachment
  group = aws_iam_group.this.name
}