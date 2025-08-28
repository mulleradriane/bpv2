resource "aws_api_gateway_base_path_mapping" "this" {
  for_each = { for mapping in var.mappings : mapping.key => mapping }

  api_id      = each.value.api_id
  stage_name  = each.value.stage_name
  domain_name = each.value.domain_name
  base_path   = each.value.base_path

  # lifecycle para evitar recreação desnecessária
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      stage_name # Stage pode ser atualizado sem recrear mapping
    ]
  }
}

# Data source para verificar se o domain name existe
data "aws_api_gateway_domain_name" "validation" {
  for_each = { for mapping in var.mappings : mapping.key => mapping }

  domain_name = each.value.domain_name

  # lifecycle para evitar erro se domain não existir ainda
  lifecycle {
    postcondition {
      condition     = self.regional_domain_name != null || self.cloudfront_domain_name != null
      error_message = "Domain name ${each.value.domain_name} does not exist or is not properly configured."
    }
  }
}