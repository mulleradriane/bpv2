locals {
  merged_request_params = {
    for m_name, cfg in var.methods : m_name => merge(
      { for p, req in try(cfg.request_parameters.path, {})   : "method.request.path.${p}"        => req },
      { for q, req in try(cfg.request_parameters.query, {})  : "method.request.querystring.${q}" => req },
      { for h, req in try(cfg.request_parameters.header, {}) : "method.request.header.${h}"      => req }
    )
  }

  integration_request_params = {
    for m_name, cfg in var.methods : m_name => merge(
      { for p, req in try(cfg.request_parameters.path, {})   : "integration.request.path.${p}"        => "method.request.path.${p}"        if req },
      { for q, req in try(cfg.request_parameters.query, {})  : "integration.request.querystring.${q}" => "method.request.querystring.${q}" if req },
      { for h, req in try(cfg.request_parameters.header, {}) : "integration.request.header.${h}"      => "method.request.header.${h}"      if req }
    )
  }

  # Flatten method responses para facilitar iteração
  all_responses = merge([
    for method, responses in var.method_responses : {
      for status, cfg in responses :
      "${method}_${status}" => {
        method = method
        status = status
        config = cfg
      }
    }
  ]...)

  # Flatten integration response selection patterns
  integration_responses_flattened = merge([
    for method_name, patterns in var.integration_response_selection_patterns : {
      for status_code, pattern in patterns :
      "${method_name}_${status_code}" => {
        method_name    = method_name
        status_code    = status_code
        selection_pattern = pattern
      }
    }
  ]...)
}

##############################
# Method
##############################
resource "aws_api_gateway_method" "this" {
  for_each           = var.methods
  rest_api_id        = var.rest_api_id
  resource_id        = var.resource_id
  http_method        = each.key
  authorization      = var.authorization
  api_key_required   = false
  request_parameters = local.merged_request_params[each.key]
  request_models     = each.value.request_models
  request_validator_id = try(aws_api_gateway_request_validator.this[each.key].id, null)
}

##############################
# Integration
##############################
resource "aws_api_gateway_integration" "this" {
  for_each                  = var.methods
  rest_api_id               = var.rest_api_id
  resource_id               = var.resource_id
  http_method               = aws_api_gateway_method.this[each.key].http_method
  type                      = each.value.integration_type
  uri                       = contains(["AWS", "AWS_PROXY", "HTTP", "HTTP_PROXY"], each.value.integration_type) ? each.value.uri : null
  integration_http_method   = contains(["AWS", "AWS_PROXY", "HTTP", "HTTP_PROXY"], each.value.integration_type) ? coalesce(each.value.integration_http_method, "POST") : null
  connection_type           = each.value.integration_type == "VPC_LINK" ? coalesce(each.value.connection_type, "VPC_LINK") : null
  connection_id             = each.value.integration_type == "VPC_LINK" ? each.value.connection_id : null
  passthrough_behavior      = "WHEN_NO_MATCH"
  timeout_milliseconds      = each.value.timeout
  request_parameters        = local.integration_request_params[each.key]
  request_templates         = each.value.request_templates

  depends_on = [aws_api_gateway_method.this]
}

##############################
# Request Validators
##############################
resource "aws_api_gateway_request_validator" "this" {
  for_each    = var.request_validators
  name        = "${each.value}-${each.key}-validator"
  rest_api_id = var.rest_api_id

  validate_request_body       = can(regex("body", lower(each.value)))
  validate_request_parameters = can(regex("parameters|query|header", lower(each.value)))
}

##############################
# Method Responses Customizados
##############################
resource "aws_api_gateway_method_response" "custom" {
  for_each = local.all_responses

  rest_api_id         = var.rest_api_id
  resource_id         = var.resource_id
  http_method         = each.value.method
  status_code         = each.value.status
  response_models     = each.value.config.response_models
  response_parameters = each.value.config.response_parameters

  depends_on = [aws_api_gateway_method.this]
}

##############################
# Method Responses CORS (apenas se não houver custom response 200)
##############################
resource "aws_api_gateway_method_response" "cors" {
  for_each = {
    for k, v in var.methods :
    k => v
    if v.enable_cors && !contains(keys(try(var.method_responses[k], {})), "200")
  }

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [aws_api_gateway_method.this]
}

##############################
# Method Responses Default (sem CORS, sem custom)
##############################
resource "aws_api_gateway_method_response" "default" {
  for_each = {
    for k, v in var.methods :
    k => v
    if !v.enable_cors && !contains(keys(try(var.method_responses[k], {})), "200")
  }

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [aws_api_gateway_method.this]
}

##############################
# Integration Responses Customizados (com selection pattern)
##############################
resource "aws_api_gateway_integration_response" "custom_with_pattern" {
  for_each = local.integration_responses_flattened

  rest_api_id       = var.rest_api_id
  resource_id       = var.resource_id
  http_method       = each.value.method_name
  status_code       = each.value.status_code
  selection_pattern = each.value.selection_pattern

  # Busca response_templates da configuração custom se existir
  response_templates = try(
    var.method_responses[each.value.method_name][each.value.status_code].response_templates,
    { "application/json" = "" }
  )

  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_method_response.custom
  ]
}

##############################
# Integration Responses Customizados (sem selection pattern, exceto 200)
##############################
resource "aws_api_gateway_integration_response" "custom" {
  for_each = {
    for k, v in local.all_responses :
    k => v
    if v.status != "200" && !contains(keys(try(var.integration_response_selection_patterns[v.method], {})), v.status)
  }

  rest_api_id        = var.rest_api_id
  resource_id        = var.resource_id
  http_method        = each.value.method
  status_code        = each.value.status
  response_templates = each.value.config.response_templates

  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_method_response.custom
  ]
}

##############################
# Integration Response CORS (200 com CORS, sem custom, sem pattern)
##############################
resource "aws_api_gateway_integration_response" "cors" {
  for_each = {
    for method_name, method_config in var.methods :
    method_name => method_config
    if method_config.enable_cors &&
       !contains(keys(try(var.method_responses[method_name], {})), "200") &&
       !contains(keys(try(var.integration_response_selection_patterns[method_name], {})), "200")
  }

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = var.cors_allow_headers
    "method.response.header.Access-Control-Allow-Methods" = var.cors_allow_methods
    "method.response.header.Access-Control-Allow-Origin"  = var.cors_allow_origin
  }

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_method_response.cors
  ]
}

##############################
# Integration Response Default (200 sem CORS, sem custom, sem pattern)
##############################
resource "aws_api_gateway_integration_response" "default" {
  for_each = {
    for method_name, method_config in var.methods :
    method_name => method_config
    if !method_config.enable_cors &&
       !contains(keys(try(var.method_responses[method_name], {})), "200") &&
       !contains(keys(try(var.integration_response_selection_patterns[method_name], {})), "200")
  }

  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = each.key
  status_code = "200"

  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.this,
    aws_api_gateway_method_response.default
  ]
}