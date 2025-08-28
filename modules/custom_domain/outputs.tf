output "domain_name" {
  description = "Nome do domínio customizado"
  value       = aws_api_gateway_domain_name.this.domain_name
}

output "domain_name_id" {
  description = "ID do domain name"
  value       = aws_api_gateway_domain_name.this.id
}

output "regional_domain_name" {
  description = "Nome de domínio regional (para endpoints REGIONAL)"
  value       = aws_api_gateway_domain_name.this.regional_domain_name
}

output "regional_zone_id" {
  description = "Zone ID regional (para endpoints REGIONAL)"
  value       = aws_api_gateway_domain_name.this.regional_zone_id
}

output "cloudfront_domain_name" {
  description = "Nome de domínio CloudFront (para endpoints EDGE)"
  value       = aws_api_gateway_domain_name.this.cloudfront_domain_name
}

output "cloudfront_zone_id" {
  description = "Zone ID CloudFront (para endpoints EDGE)"
  value       = aws_api_gateway_domain_name.this.cloudfront_zone_id
}

output "security_policy" {
  description = "Política de segurança TLS configurada"
  value       = aws_api_gateway_domain_name.this.security_policy
}

output "mutual_tls_enabled" {
  description = "Indica se mTLS está habilitado"
  value       = var.mutual_tls_truststore_uri != null
}

output "arn" {
  description = "ARN completo do domain name"
  value       = aws_api_gateway_domain_name.this.arn
}

output "api_gateway_domain_console_url" {
  description = "URL do console AWS para este domain name"
  value       = "https://${var.region}.console.aws.amazon.com/apigateway/home?region=${var.region}#/custom-domain-names/${aws_api_gateway_domain_name.this.id}"
}