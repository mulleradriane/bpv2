output "resource_ids" {
  description = "Mapa de IDs dos recursos criados"
  value       = { for k, v in aws_api_gateway_resource.this : k => v.id }
}

output "resources_paths" {
  description = "Mapa de paths dos recursos criados"
  value       = { for k, v in aws_api_gateway_resource.this : k => v.path }
}

output "resources_hash" {
  description = "Hash único dos recursos para triggers de deployment"
  value       = sha1(jsonencode({
    for k, v in aws_api_gateway_resource.this : k => {
      id   = v.id
      path = v.path
    }
  }))
}

output "resources_count" {
  description = "Número total de recursos criados"
  value       = length(aws_api_gateway_resource.this)
}