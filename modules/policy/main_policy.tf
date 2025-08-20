resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = var.rest_api_id
  policy      = var.policy
}
