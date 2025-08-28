resource "aws_acm_certificate" "this" {
  domain_name       = var.domain_name
  validation_method = var.validation_method
  subject_alternative_names = var.san_names

  # Forçar TLS 1.2+ - CRÍTICO para governança
  options {
    certificate_transparency_logging_preference = var.certificate_transparency_logging ? "ENABLED" : "DISABLED"
  }

  tags = merge(var.tags, {
    TLS_Version = "1.2" # Metadata para tracking
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      options # Evita drift com configurações de TLS
    ]
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => dvo
    if var.validation_method == "DNS" && var.route53_zone_id != null
  }

  zone_id = var.route53_zone_id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  ttl     = 300 #300s (5min) - melhor performance
  records = [each.value.resource_record_value]

  allow_overwrite = true # Importante para ambientes de reuso
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn
  validation_record_fqdns = var.validation_method == "DNS" ? [
    for record in aws_route53_record.cert_validation : record.fqdn
  ] : []

  timeouts {
    create = "15m" # Aumentado timeout para certificados grandes
  }

  lifecycle {
    precondition {
      condition = (
        (var.validation_method == "DNS" && var.route53_zone_id != null) ||
        (var.validation_method == "EMAIL") ||
        (var.validation_method == "NONE")
      )
      error_message = "Para validação DNS, route53_zone_id é obrigatório."
    }
  }
}