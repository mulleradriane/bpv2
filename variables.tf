variable "environment" {
  description = "Ambiente (ex.: dev, hml, prd)"
  type        = string
  default     = "dev"
}

variable "product" {
  description = "Produto associado à API"
  type        = string
}

variable "application" {
  description = "Aplicação relacionada"
  type        = string
  default     = ""
}

variable "ticket" {
  description = "Ticket ou ID de referência"
  type        = string
  default     = ""
}

variable "blueprint" {
  description = "Nome da blueprint"
  type        = string
  default     = "apigateway-v1"
}

variable "custom_tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}

variable "legacy_name" {
  description = "Nome legado, se aplicável"
  type        = string
  default     = null
}

variable "default_allowed_ips" {
  description = "Lista de IPs liberados por default para o API Gateway"
  type        = list(string)
  default     = ["192.0.2.0/24", "198.51.100.0/24"]  # Ajuste para IPs das apigw
}

variable "custom_api_policy" {
  description = "Policy JSON completa para override no API Gateway"
  type        = string
  default     = null
}

variable "deny_rules" {
  description = "Regras de Deny custom para API Gateway policy"
  type        = map(any)
  default     = {}
}

variable "enable_human_iam" {
  description = "Habilita criação de IAM para usuários humanos (legacy)"
  type        = bool
  default     = false
}

variable "legacy_user_group_name" {
  description = "Nome legado para grupo IAM, se aplicável"
  type        = string
  default     = null
}

variable "legacy_policy_name" {
  description = "Nome legado para policy IAM, se aplicável"
  type        = string
  default     = null
}

variable "users_to_attachment" {
  description = "Lista de usuários para anexar ao grupo IAM (legacy)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags corporativas (geradas por módulo externo no futuro)"
  type        = map(string)
  default     = {}
}