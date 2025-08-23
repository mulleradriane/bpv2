##############################
# Deployment Outputs
##############################
output "deployment_id" {
  value       = aws_api_gateway_deployment.this.id
  description = "ID do deployment"
}

output "deployment_description" {
  value       = aws_api_gateway_deployment.this.description
  description = "Descrição do deployment"
}

output "deployment_created_date" {
  value       = aws_api_gateway_deployment.this.created_date
  description = "Data de criação do deployment"
}

##############################
# Stage Outputs
##############################
output "stage_name" {
  value       = aws_api_gateway_stage.this.stage_name
  description = "Nome do stage"
}

output "stage_arn" {
  value       = aws_api_gateway_stage.this.arn
  description = "ARN do stage"
}

output "invoke_url" {
  value       = aws_api_gateway_stage.this.invoke_url
  description = "URL de invocação da API"
}

output "stage_variables" {
  value       = aws_api_gateway_stage.this.variables
  description = "Variáveis do stage"
}

output "execution_arn" {
  value       = aws_api_gateway_stage.this.execution_arn
  description = "ARN de execução do stage"
}

##############################
# Cache Outputs
##############################
output "cache_cluster_enabled" {
  value       = aws_api_gateway_stage.this.cache_cluster_enabled
  description = "Status do cache cluster"
}

output "cache_cluster_size" {
  value       = aws_api_gateway_stage.this.cache_cluster_size
  description = "Tamanho do cache cluster"
}

##############################
# Custom Domain Outputs
##############################
output "domain_name" {
  value       = var.domain_name != null ? aws_api_gateway_domain_name.this[0].domain_name : null
  description = "Nome do domínio customizado"
}

# output "domain_cloudfront_distribution_id" {
#   value       = var.domain_name != null ? aws_api_gateway_domain_name.this[0].cloudfront_distribution_id : null
#   description = "ID da distribuição CloudFront do domínio"
# }

output "domain_cloudfront_domain_name" {
  value       = var.domain_name != null ? aws_api_gateway_domain_name.this[0].cloudfront_domain_name : null
  description = "Nome do domínio CloudFront"
}

output "domain_regional_domain_name" {
  value       = var.domain_name != null ? aws_api_gateway_domain_name.this[0].regional_domain_name : null
  description = "Nome do domínio regional"
}

output "domain_regional_zone_id" {
  value       = var.domain_name != null ? aws_api_gateway_domain_name.this[0].regional_zone_id : null
  description = "Zone ID do domínio regional"
}

# ##############################
# # CloudWatch Outputs
# ##############################
# output "log_group_name" {
#   value       = var.logging_level != null && var.logging_level != "OFF" ? aws_cloudwatch_log_group.api_gateway[0].name : null
#   description = "Nome do CloudWatch Log Group"
# }

# output "log_group_arn" {
#   value       = var.logging_level != null && var.logging_level != "OFF" ? aws_cloudwatch_log_group.api_gateway[0].arn : null
#   description = "ARN do CloudWatch Log Group"
# }

# ##############################
# # Debugging Outputs
# ##############################
# output "triggers_sha" {
#   value       = var.triggers_sha
#   description = "Hash atual usado como trigger"
# }