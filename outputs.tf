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

output "api_policy" {
  description = "Policy JSON aplicada ao API Gateway"
  value       = module.api_policy.policy
}

output "ci_role_arn" {
  description = "ARN da role IAM para CI/CD"
  value       = module.iam_service.role_arn
}

output "user_group_name" {
  description = "Nome do grupo IAM para usuários humanos (se habilitado)"
  value       = var.enable_human_iam ? module.user_group[0].name : null
}