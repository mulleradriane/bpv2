output "api_id" {
  description = "ID da API Gateway REST"
  value       = module.api.id
}

output "api_root_resource_id" {
  description = "ID do recurso raiz da API"
  value       = module.api.root_resource_id
}

output "deployment_id" {
  description = "ID do deployment atual"
  value       = module.deployment.deployment_id
}

output "stage_name" {
  description = "Nome do stage"
  value       = module.deployment.stage_name
}

output "invoke_url" {
  description = "URL de invocação da API"
  value       = module.deployment.invoke_url
}

output "stage_arn" {
  description = "ARN do stage"
  value       = module.deployment.stage_arn
}

output "methods_hash" {
  description = "Hash atual dos métodos (para debug)"
  value       = local.methods_hash
}