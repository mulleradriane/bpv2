locals {
  # Hash mais para triggers de deployment
  deployment_hash = sha1(join("", [
    jsonencode(var.redeploy_triggers),
    jsonencode(var.stage_variables),
    var.stage_name
  ]))
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = var.api_id
  description = "Deployment for ${var.stage_name} created at ${timestamp()}"

  # Triggers mais robustos
  triggers = {
    redeploy_hash = sha1(jsonencode({
      resources = var.redeploy_triggers.resources
      methods   = var.redeploy_triggers.methods
      api_id    = var.api_id
      timestamp = timestamp()
    }))
  }

  # Dependências explícitas para evitar race condition
  depends_on = [
    var.methods_dependency,  # Dependência dos métodos/integrações
    var.resources_dependency # Dependência dos recursos
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [description]
  }
}
resource "aws_api_gateway_stage" "this" {
  rest_api_id   = var.api_id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.stage_name

  description           = var.stage_description
  cache_cluster_enabled = var.cache_cluster_enabled
  cache_cluster_size    = var.cache_cluster_size
  xray_tracing_enabled  = var.xray_tracing_enabled
  variables            = var.stage_variables

  # Configurações de acesso e TLS
  dynamic "access_log_settings" {
    for_each = var.access_log_destination_arn != null ? [1] : []
    content {
      destination_arn = var.access_log_destination_arn
      format          = var.access_log_format
    }
  }

  tags = merge(var.tags, {
    Environment = var.stage_name
    LastDeploy  = timestamp()
  })

  # Garante que stage não é recriado desnecessariamente
  lifecycle {
    ignore_changes = [tags["LastDeploy"]]
  }
}

