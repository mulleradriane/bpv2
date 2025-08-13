##############################
# API Gateway Deployment
##############################
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = var.rest_api_id
  
  # Força novo deployment quando métodos/integrações mudam
  triggers = {
    redeploy = var.triggers_sha
  }

  # Descrição automática com timestamp ou personalizada
  description = var.deployment_description != null ? var.deployment_description : "Deployment created at ${timestamp()} - Hash: ${substr(var.triggers_sha, 0, 8)}"

  lifecycle {
    create_before_destroy = true
  }
}

##############################
# API Gateway Stage
##############################
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = var.rest_api_id
  stage_name    = var.stage_name
  
  # Stage variables
  variables = var.stage_variables
  
  # Descrição do stage
  description = var.stage_description != null ? var.stage_description : "Stage ${var.stage_name} managed by Terraform"
  
  # Cache settings
  cache_cluster_enabled = var.cache_cluster_enabled
  cache_cluster_size    = var.cache_cluster_enabled ? var.cache_cluster_size : null
  
  # Tags
  tags = var.tags
}

##############################
# Method Settings (Throttling, Caching, Logging)
##############################
resource "aws_api_gateway_method_settings" "this" {
  count = var.throttle_settings != null || var.logging_level != null || var.cache_cluster_enabled ? 1 : 0
  
  rest_api_id = var.rest_api_id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    # Throttling
    throttling_rate_limit  = var.throttle_settings != null ? var.throttle_settings.rate_limit : null
    throttling_burst_limit = var.throttle_settings != null ? var.throttle_settings.burst_limit : null
    
    # Logging
    logging_level      = var.logging_level
    data_trace_enabled = var.data_trace_enabled
    metrics_enabled    = var.metrics_enabled
    
    # Caching
    caching_enabled                = var.cache_cluster_enabled
    cache_ttl_in_seconds          = var.cache_cluster_enabled ? var.cache_ttl_in_seconds : null
    cache_data_encrypted          = var.cache_cluster_enabled ? var.cache_data_encrypted : null
    require_authorization_for_cache_control = var.cache_cluster_enabled ? var.require_authorization_for_cache_control : null
    unauthorized_cache_control_header_strategy = var.cache_cluster_enabled ? var.unauthorized_cache_control_header_strategy : null
  }
}

##############################
# CloudWatch Log Group (para API Gateway logs)
##############################
resource "aws_cloudwatch_log_group" "api_gateway" {
  count = var.logging_level != null && var.logging_level != "OFF" ? 1 : 0
  
  name              = "/aws/apigateway/${var.rest_api_id}/${var.stage_name}"
  retention_in_days = var.log_retention_in_days
  
  tags = var.tags
}

##############################
# API Gateway Account (necessário para logging)
##############################
data "aws_iam_policy_document" "api_gateway_logs" {
  count = var.logging_level != null && var.logging_level != "OFF" && var.create_log_role ? 1 : 0
  
  statement {
    effect = "Allow"
    
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "api_gateway_logs" {
  count = var.logging_level != null && var.logging_level != "OFF" && var.create_log_role ? 1 : 0
  
  name               = "${var.stage_name}-api-gateway-logs-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_logs[0].json
  
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "api_gateway_logs" {
  count = var.logging_level != null && var.logging_level != "OFF" && var.create_log_role ? 1 : 0
  
  role       = aws_iam_role.api_gateway_logs[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  count = var.logging_level != null && var.logging_level != "OFF" && var.create_log_role ? 1 : 0
  
  cloudwatch_role_arn = aws_iam_role.api_gateway_logs[0].arn
}

##############################
# Custom Domain (opcional)
##############################
resource "aws_api_gateway_domain_name" "this" {
  count = var.domain_name != null ? 1 : 0
  
  domain_name              = var.domain_name
  regional_certificate_arn = var.certificate_arn
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = var.tags
}

resource "aws_api_gateway_base_path_mapping" "this" {
  count = var.domain_name != null ? 1 : 0
  
  api_id      = var.rest_api_id
  stage_name  = aws_api_gateway_stage.this.stage_name
  domain_name = aws_api_gateway_domain_name.this[0].domain_name
  base_path   = var.base_path
}