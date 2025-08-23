##############################
# Method IDs (existente)
##############################
output "method_ids" {
  value = {
    for k, m in aws_api_gateway_method.this :
    k => m.id
  }
}

##############################
# Method Configuration para Deployment Hash (CRÍTICO)
##############################
output "method_configs" {
  description = "Configurações dos métodos criados"
  value       = { for method_name, config in aws_api_gateway_integration.this : method_name => {
    integration_type    = config.type
    uri                 = config.uri
    request_templates   = config.request_templates
    request_parameters  = config.request_parameters
  } }
}

# ##############################
# # ARNs dos Recursos
# ##############################
# output "method_arns" {
#   description = "ARNs dos métodos criados"
#   value = {
#     for method_name in keys(var.methods) : method_name => aws_api_gateway_method.this[method_name].arn
#   }
# }

# output "integration_arns" {
#   description = "ARNs das integrações criadas"
#   value = {
#     for method_name in keys(var.methods) : method_name => aws_api_gateway_integration.this[method_name].arn
#   }
# }

##############################
# Detalhes dos Métodos
##############################
output "methods" {
  description = "Detalhes dos métodos criados"
  value = {
    for method_name in keys(var.methods) : method_name => {
      http_method    = aws_api_gateway_method.this[method_name].http_method
      authorization  = aws_api_gateway_method.this[method_name].authorization
      resource_id    = aws_api_gateway_method.this[method_name].resource_id
      api_key_required = aws_api_gateway_method.this[method_name].api_key_required
    }
  }
}

##############################
# CORS Configuration
##############################
output "cors_configuration" {
  description = "Configuração CORS aplicada"
  value = var.cors_allow_origin != null ? {
    allow_origin  = var.cors_allow_origin
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
  } : null
}

##############################
# Request Validators
##############################
output "request_validators" {
  description = "Validadores de request configurados"
  value = length(var.request_validators) > 0 ? {
    for method_name, validator_name in var.request_validators : method_name => {
      name = validator_name
      id   = aws_api_gateway_request_validator.this[method_name].id
    }
  } : {}
}

##############################
# Method Responses
##############################
output "method_responses" {
  description = "Responses configurados por método"
  value = var.method_responses != null ? var.method_responses : {}
}

##############################
# Integration Response Selection Patterns
##############################
output "integration_response_selection_patterns" {
  description = "Selection patterns configurados"
  value = var.integration_response_selection_patterns
}