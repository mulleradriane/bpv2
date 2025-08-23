#SOMENTE CASO NECESSARIO, MAS ACHO QUE AS ROLES DE CI/CD JA ESTAO PRONTAS.check "

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = var.assume_role_policy
  tags               = var.tags
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name}-policy"
  role   = aws_iam_role.this.id
  policy = var.policy_json
}

