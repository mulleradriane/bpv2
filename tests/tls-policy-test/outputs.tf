output "test_results" {
  description = "Resultados do teste de TLS policy"
  value       = module.tls_policy.tls_policy_status
}

output "migration_summary" {
  description = "Sumário da migração TLS"
  value       = "${module.tls_policy.migrated_count} domínios migrados para TLS 1.2+"
}