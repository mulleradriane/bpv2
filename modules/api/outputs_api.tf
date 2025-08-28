output "api_id" {
  description = "ID da API REST"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "ARN da API REST"
  value       = aws_api_gateway_rest_api.this.arn
}

output "root_resource_id" {
  description = "ID do recurso raiz da API"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "execution_arn" {
  description = "ARN de execução da API"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "api_name" {
  description = "Nome da API"
  value       = aws_api_gateway_rest_api.this.name
}

output "endpoint_type" {
  description = "Tipo de endpoint configurado"
  value       = var.endpoint_type
}