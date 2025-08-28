output "base_path_mappings" {
  description = "Mapa de base path mappings criados"
  value       = { for k, v in aws_api_gateway_base_path_mapping.this : k => v }
}

output "mapping_ids" {
  description = "IDs dos base path mappings"
  value       = { for k, v in aws_api_gateway_base_path_mapping.this : k => v.id }
}

output "mapping_details" {
  description = "Detalhes completos dos mappings"
  value = [ for mapping in aws_api_gateway_base_path_mapping.this : {
    domain_name = mapping.domain_name
    base_path   = mapping.base_path
    api_id      = mapping.api_id
    stage_name  = mapping.stage_name
    mapping_id  = mapping.id
  }]
}

output "validation_status" {
  description = "Status de validação dos domain names"
  value       = { for k, v in data.aws_api_gateway_domain_name.validation : k => v.domain_name }
  sensitive   = true
}