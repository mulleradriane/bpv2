locals {
  methods = {
    for idx, m in var.methods : idx => merge(
      {
        http_method      = m.http_method
        resource_id      = m.resource_id
        integration_type = lookup(m, "integration_type", "MOCK")
      },
      m
    )
  }

  resolved_integration_uri = {
    for k, m in local.methods : k =>
    (
      m.integration_type == "AWS_PROXY" && lookup(m, "lambda_arn", null) != null ?
      "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${m.lambda_arn}/invocations" :
      lookup(m, "integration_uri", null)
    )
  }

  resource_path = {
    for k, m in local.methods : k =>
    (
      lookup(m, "resource_path", null) != null ? m.resource_path : "/"
    )
  }
}

resource "aws_api_gateway_method" "this" {
  for_each    = local.methods
  rest_api_id = var.api_id
  resource_id = each.value.resource_id
  http_method = upper(each.value.http_method)

  authorization      = lookup(each.value, "authorization", "NONE")
  authorizer_id      = lookup(each.value, "authorizer_id", null)
  api_key_required   = lookup(each.value, "api_key_required", false)

  request_parameters   = lookup(each.value, "request_parameters", {})
  request_models       = lookup(each.value, "request_models", {})
  request_validator_id = lookup(each.value, "request_validator_id", null)

  lifecycle {
    ignore_changes = [request_parameters, request_models]
  }
}

resource "aws_api_gateway_integration" "this" {
  for_each    = local.methods
  rest_api_id = var.api_id
  resource_id = each.value.resource_id
  http_method = aws_api_gateway_method.this[each.key].http_method

  type = lookup(each.value, "integration_type", "MOCK")

  # integration_http_method só é usado para AWS/HTTP
  integration_http_method = (
    contains(["AWS", "HTTP", "HTTP_PROXY"], lookup(each.value, "integration_type", "MOCK")) ?
    lookup(each.value, "integration_http_method", "POST") :
    null
  )

  uri                  = local.resolved_integration_uri[each.key]
  connection_type      = lookup(each.value, "connection_type", null)
  connection_id        = lookup(each.value, "connection_id", null)
  credentials          = lookup(each.value, "credentials", null)
  passthrough_behavior = lookup(each.value, "passthrough_behavior", null)
  timeout_milliseconds = lookup(each.value, "timeout_milliseconds", null)
  cache_key_parameters = lookup(each.value, "cache_key_parameters", [])
  cache_namespace      = lookup(each.value, "cache_namespace", null)
  content_handling     = lookup(each.value, "content_handling", null)

  request_templates = lookup(each.value, "request_templates", {})

  dynamic "tls_config" {
    for_each = lookup(each.value, "tls_config", null) != null ? [1] : []
    content {
      insecure_skip_verification = lookup(each.value.tls_config, "insecure_skip_verification", false)
    }
  }
}

resource "aws_api_gateway_method_response" "per_status" {
  for_each = {
    for combo in flatten([
      for method_key, method in local.methods : [
        for status_code, response_config in lookup(method, "method_responses", {}) : {
          method_key  = method_key
          status_code = status_code
          config      = response_config
        }
      ]
    ]) : "${combo.method_key}-${combo.status_code}" => combo
  }

  rest_api_id = var.api_id
  resource_id = local.methods[each.value.method_key].resource_id
  http_method = aws_api_gateway_method.this[each.value.method_key].http_method
  status_code = each.value.status_code

  response_models     = lookup(each.value.config, "response_models", {})
  response_parameters = lookup(each.value.config, "response_parameters", {})

  lifecycle {
    ignore_changes = [
      response_parameters,
      response_models
    ]
  }
}

resource "aws_api_gateway_integration_response" "per_status" {
  for_each = {
    for combo in flatten([
      for method_key, method in local.methods : [
        for status_code, response_config in lookup(method, "integration_responses", {}) : {
          method_key  = method_key
          status_code = status_code
          config      = response_config
        }
      ]
    ]) : "${combo.method_key}-${combo.status_code}" => combo
  }

  rest_api_id = var.api_id
  resource_id = local.methods[each.value.method_key].resource_id
  http_method = aws_api_gateway_method.this[each.value.method_key].http_method
  status_code = each.value.status_code

  # Adicionar dependência explícita da integration
  depends_on = [aws_api_gateway_integration.this]

  response_templates  = lookup(each.value.config, "response_templates", {})
  response_parameters = lookup(each.value.config, "response_parameters", {})
  selection_pattern   = lookup(each.value.config, "selection_pattern", null)
  content_handling    = lookup(each.value.config, "content_handling", null)
}

# Lambda permission opcional (quando integration_type = AWS_PROXY e lambda_arn informado)
resource "aws_lambda_permission" "allow_api_gw" {
  for_each = {
    for k, m in local.methods :
    k => m if m.integration_type == "AWS_PROXY" && lookup(m, "lambda_arn", null) != null
  }

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "apigateway.amazonaws.com"

  # O source_arn mais restritivo para melhor segurança
  source_arn = "${var.api_execution_arn}/*/${each.value.http_method}${local.resource_path[each.key]}"
}

