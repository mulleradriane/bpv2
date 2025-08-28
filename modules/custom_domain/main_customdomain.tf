resource "aws_api_gateway_domain_name" "this" {
  domain_name              = var.domain_name
  regional_certificate_arn = var.endpoint_type == "REGIONAL" ? var.certificate_arn : null
  certificate_arn          = var.endpoint_type == "EDGE" ? var.certificate_arn : null
  security_policy          = var.security_policy

  # Configuração de mTLS (quando fornecido)
  dynamic "mutual_tls_authentication" {
    for_each = var.mutual_tls_truststore_uri != null ? [1] : []
    content {
      truststore_uri     = var.mutual_tls_truststore_uri
      truststore_version = var.mutual_tls_truststore_version
    }
  }

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = merge(var.tags, {
    ManagedBy      = "Terraform"
    EndpointType   = var.endpoint_type
    SecurityPolicy = var.security_policy
    MutualTLS      = var.mutual_tls_truststore_uri != null ? "enabled" : "disabled"
    Environment    = var.environment
  })

  lifecycle {
    ignore_changes = [
      regional_certificate_arn, # Pode mudar durante renovação do certificado
      certificate_arn,
      ownership_verification_certificate_arn
    ]
  }
}

# Record Route53 para o domain name (opcional)
resource "aws_route53_record" "this" {
  count = var.create_route53_record ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = var.endpoint_type == "REGIONAL" ? "A" : "CNAME"

  alias {
    name                   = var.endpoint_type == "REGIONAL" ? aws_api_gateway_domain_name.this.regional_domain_name : aws_api_gateway_domain_name.this.cloudfront_domain_name
    zone_id                = var.endpoint_type == "REGIONAL" ? aws_api_gateway_domain_name.this.regional_zone_id : aws_api_gateway_domain_name.this.cloudfront_zone_id
    evaluate_target_health = false
  }
}