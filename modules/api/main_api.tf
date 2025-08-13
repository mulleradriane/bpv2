resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = var.description
}

# 🚫 Comentamos por agora, até ter métodos criados
# resource "aws_api_gateway_deployment" "this" {
#   depends_on  = [aws_api_gateway_rest_api.this]
#   rest_api_id = aws_api_gateway_rest_api.this.id
# }

# resource "aws_api_gateway_stage" "this" {
#   rest_api_id   = aws_api_gateway_rest_api.this.id
#   deployment_id = aws_api_gateway_deployment.this.id
#   stage_name    = var.stage_name
# }
