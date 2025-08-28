output "stage_name" {
  description = "Nome do stage"
  value       = aws_api_gateway_stage.this.stage_name
}

output "deployment_id" {
  description = "ID do deployment"
  value       = aws_api_gateway_deployment.this.id
}

output "invoke_url" {
  description = "URL de invocação do stage"
  value       = "https://${var.api_id}.execute-api.${var.region}.amazonaws.com/${var.stage_name}"
}

output "stage_object" {
  description = "Objeto completo do stage para debugging"
  value       = aws_api_gateway_stage.this
  sensitive   = true
}

output "stage_arn" {
  description = "ARN do stage"
  value       = aws_api_gateway_stage.this.arn
}

output "execution_arn" {
  description = "ARN de execução do stage"
  value       = "${aws_api_gateway_stage.this.execution_arn}/*"
}

output "deployment_hash" {
  description = "Hash do deployment para referência"
  value       = local.deployment_hash
}