output "api_endpoint" {
  value = module.deployment.invoke_url
}

output "ping_url" {
  description = "URL completa do endpoint /ping"
  value       = "${module.deployment.invoke_url}/ping"
}

output "api_id" {
  description = "ID da API Gateway"
  value       = module.api.api_id
}

output "api_arn" {
  description = "ARN completo da API"
  value       = module.api.api_arn
}

output "execution_arn" {
  description = "Execution ARN para uso em políticas IAM"
  value       = module.api.execution_arn
}

output "stage_name" {
  description = "Nome do stage deployado"
  value       = module.deployment.stage_name
}

output "deployment_id" {
  description = "ID do deployment atual"
  value       = module.deployment.deployment_id
}

output "root_resource_id" {
  description = "ID do recurso raiz da API"
  value       = module.api.root_resource_id
}

output "ping_resource_id" {
  description = "ID do recurso /ping"
  value       = module.root_resource.resource_ids["ping"]
}

output "method_details" {
  description = "Detalhes do método GET /ping"
  value       = module.ping_method.methods["GET_ping"]
}

output "cloudwatch_url" {
  description = "URL para logs do CloudWatch (se habilitado)"
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#logsV2:log-groups/log-group/$252Faws$252Fapigateway$252F${module.api.api_name}"
}

# Outputs para teste rápido
output "test_curl_command" {
  description = "Comando curl para testar o endpoint /ping"
  value       = "curl -X GET '${module.deployment.invoke_url}/ping'"
}

output "test_browser_url" {
  description = "URL para testar no navegador"
  value       = "${module.deployment.invoke_url}/ping"
}

output "api_gateway_console_url" {
  description = "URL do console da AWS para esta API"
  value       = "https://${var.region}.console.aws.amazon.com/apigateway/home?region=${var.region}#/apis/${module.api.api_id}/resources/"
}

output "real_invoke_url" {
  description = "URL real de invocação (corrigida)"
  value       = "https://${module.api.api_id}.execute-api.${var.region}.amazonaws.com/${module.deployment.stage_name}"
}

output "ping_url_corrected" {
  description = "URL do ping corrigida"
  value       = "https://${module.api.api_id}.execute-api.${var.region}.amazonaws.com/${module.deployment.stage_name}/ping"
}

output "test_results" {
  description = "Resultados do teste de base path mapping"
  value       = module.base_path_mapping.mapping_details
}

output "validation_info" {
  description = "Informações de validação"
  value       = "Domain names fictícios - validação simulada para teste"
}