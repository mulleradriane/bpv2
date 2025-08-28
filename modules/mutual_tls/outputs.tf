output "mtls_domains" {
  description = "Domínios com mTLS configurado"
  value       = aws_api_gateway_domain_name.mtls
}

output "client_policy_arn" {
  description = "ARN da política IAM para clientes mTLS"
  value       = var.create_client_policy ? aws_iam_policy.mtls_client[0].arn : null
}

output "mtls_domain_names" {
  description = "Nomes dos domínios com mTLS"
  value       = [for domain in aws_api_gateway_domain_name.mtls : domain.domain_name]
}

output "mtls_validation_status" {
  description = "Status de validação mTLS por domínio"
  value = { for name, domain in aws_api_gateway_domain_name.mtls : name => {
    domain_name    = domain.domain_name
    mTLS_enabled   = domain.mutual_tls_authentication != null
    truststore_uri = try(domain.mutual_tls_authentication[0].truststore_uri, null)
  }}
}

output "truststore_bucket" {
  description = "Bucket S3 do truststore (se criado)"
  value       = var.create_truststore_bucket ? aws_s3_bucket.truststore[0] : null
}

output "truststore_object" {
  description = "Objeto truststore no S3 (se enviado)"
  value       = var.truststore_file_path != null ? aws_s3_object.truststore[0] : null
}