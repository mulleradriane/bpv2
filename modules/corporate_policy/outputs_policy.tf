output "debug_policy" {
  value       = jsonencode(local.final_policy_validated)
  sensitive   = true
}

output "corporate_ips_count" {
  description = "Número de IPs corporativos aplicados"
  value       = length(var.mandatory_ips)
}

output "custom_statements_count" {
  description = "Número de statements customizados aplicados"
  value       = length(local.custom_statements)
}