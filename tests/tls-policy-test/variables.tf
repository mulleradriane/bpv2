variable "region" {
  type    = string
  default = "us-east-1"
}

variable "create_enforcement_policy" {
  description = "Criar política IAM de enforcement TLS"
  type        = bool
  default     = false  # Mantenha false para testes sem custo
}

variable "policy_name" {
  description = "Nome da política IAM"
  type        = string
  default     = "Test-TLS-Policy"
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
