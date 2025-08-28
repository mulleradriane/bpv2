output "certificate_arn" {
  description = "ARN do certificado ACM"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain" {
  description = "Domínio principal do certificado"
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "Status do certificado"
  value       = aws_acm_certificate.this.status
}

output "validation_records" {
  description = "Registros de validação DNS"
  value       = aws_route53_record.cert_validation
}

output "certificate_validated" {
  description = "Indica se o certificado foi validado"
  value       = aws_acm_certificate_validation.this.*.id != null ? true : false
}