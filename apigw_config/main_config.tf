# modules/api_gateway/main.tf
module "api_gateway" {
  source = "git::https://github.com/company/blueprints.git//modules/api_gateway?ref=v1.2.0"

  name        = var.api_name
  description = var.description
  environment = var.environment
  
  # Usa certificado corporativo padrão
  certificate_arn = data.aws_acm_certificate.default.arn
  
  # Configuração automática baseada no environment
  endpoint_type = var.environment == "prd" ? "EDGE" : "REGIONAL"
  
  resources = var.resources
}

module "custom_domain" {
  source = "git::https://github.com/company/blueprints.git//modules/custom_domain?ref=v1.2.0"

  domain_name     = "api.${var.environment}.company.com"
  certificate_arn = data.aws_acm_certificate.default.arn
  endpoint_type   = var.environment == "prd" ? "EDGE" : "REGIONAL"
  
  # Route53 automático
  create_route53_record = true
  route53_zone_id       = data.aws_route53_zone.environment.zone_id
}

module "base_path_mapping" {
  source = "git::https://github.com/company/blueprints.git//modules/base_path_mapping?ref=v1.2.0"

  mappings = [
    {
      key         = "root-mapping"
      api_id      = module.api_gateway.api_id
      stage_name  = var.environment
      domain_name = module.custom_domain.domain_name
      base_path   = var.base_path
    }
  ]
}