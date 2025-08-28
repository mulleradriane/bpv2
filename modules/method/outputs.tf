output "methods" {
  description = "Mapa de métodos criados"
  value       = aws_api_gateway_method.this
}

output "integrations" {
  description = "Mapa de integrações criadas"
  value       = aws_api_gateway_integration.this
}

output "method_responses" {
  description = "Mapa de method responses criados"
  value       = aws_api_gateway_method_response.per_status
}

output "integration_responses" {
  description = "Mapa de integration responses criados"
  value       = aws_api_gateway_integration_response.per_status
}

output "lambda_permissions" {
  description = "Permissões Lambda criadas"
  value       = aws_lambda_permission.allow_api_gw
}

output "methods_hash" {
  description = "Hash único dos métodos para triggers de deployment"
  value       = sha1(jsonencode(var.methods))
}

output "api_execution_arn" {
  description = "Execution ARN da API para uso em políticas"
  value       = var.api_execution_arn
}