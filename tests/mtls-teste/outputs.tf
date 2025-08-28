output "test_results" {
  description = "Resultados do teste mTLS"
  value       = module.mutual_tls.mtls_validation_status
}

output "test_warning" {
  description = "Aviso sobre teste com dados fictícios"
  value       = "Teste usando URIs fictícios - para produção use truststore real"
}