output "policy" {
  description = "Policy JSON aplicada"
  value       = var.policy
}

variable "rest_api_id" {
  description = "ID do API Gateway"
  type        = string
}

variable "policy" {
  description = "Policy JSON para o API Gateway"
  type        = string
}