resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = var.api_id
  policy      = jsonencode(var.policy)

  lifecycle {
    precondition {
      condition     = length(var.policy["Statement"]) > 0
      error_message = "A policy deve conter ao menos um Statement."
    }
  }
}
