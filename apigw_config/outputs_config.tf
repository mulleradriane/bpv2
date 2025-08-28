output "api_url" {
  description = "URL completa da API"
  value       = "https://api.${var.environment}.company.com/${var.base_path != null ? var.base_path : ""}"
}

output "api_id" {
  description = "ID da API Gateway"
  value       = module.api_gateway.api_id
}

output "certificate_arn" {
  description = "ARN do certificado utilizado"
  value       = data.aws_acm_certificate.default.arn
}

output "domain_name" {
  description = "Nome do domínio customizado"
  value       = module.custom_domain.domain_name
}

output "route53_zone_id" {
  description = "ID da zona Route53"
  value       = data.aws_route53_zone.environment.zone_id
}