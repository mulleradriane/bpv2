# modules/api_gateway/variables.tf
variable "api_name" {
  description = "Nome da API (sem sufixo de environment)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, hml, prd)"
  type        = string
  validation {
    condition     = contains(["dev", "hml", "prd"], var.environment)
    error_message = "Environment must be dev, hml, or prd."
  }
}

variable "base_path" {
  description = "Base path para o mapping (null para root)"
  type        = string
  default     = null
}

variable "resources" {
  description = "Recursos da API"
  type        = any
  default     = {}
}

variable "use_existing_domain" {
  description = "Usar domain name existente em vez de criar novo"
  type        = bool
  default     = false
}