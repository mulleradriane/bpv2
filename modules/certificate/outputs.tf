output "domain_name" {
  description = "Nome do domínio criado"
  value       = aws_api_gateway_domain_name.this.domain_name
}

output "certificate_arn" {
  description = "ARN do certificado usado"
  value       = aws_api_gateway_domain_name.this.certificate_arn
}

