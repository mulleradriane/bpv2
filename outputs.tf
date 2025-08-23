# outputs.tf
output "api_id" {
  description = "ID da API Gateway REST"
  value       = module.api.id
}

output "api_root_resource_id" {
  description = "ID do recurso raiz da API"
  value       = module.api.root_resource_id
}

output "deployment_ids" {
  description = "Map of deployment IDs for each stage"
  value       = { for k, v in module.deployment : k => v.deployment_id }
}

output "stage_names" {
  description = "Map of stage names for each stage"
  value       = { for k, v in module.deployment : k => v.stage_name }
}

output "invoke_urls" {
  description = "Map of invoke URLs for each stage"
  value       = { for k, v in module.deployment : k => v.invoke_url }
}

output "stage_arns" {
  description = "Map of stage ARNs for each stage"
  value       = { for k, v in module.deployment : k => v.stage_arn }
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