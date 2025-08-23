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
  default     = ["192.0.2.0/24", "198.51.100.0/24"]
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

# Novas variáveis para certificados e domínios
variable "default_certificates" {
  description = "Mapeamento de ARNs de certificados por ambiente"
  type        = map(string)
  default = {
    dev = "arn:aws:acm:us-east-1:123456789012:certificate/abc123-xyz789" #AJUSTAR CERTIFICADOS!!!
    hml = "arn:aws:acm:us-east-1:123456789012:certificate/def456-uvw012"
    prd = "arn:aws:acm:us-east-1:123456789012:certificate/ghi789-jkl345"
  }
}

variable "default_domain" {
  description = "Mapeamento de domínios por ambiente"
  type        = map(string)
  default = {
    dev = "api.dev.example.com"
    hml = "api.hml.example.com"
    prd = "api.prd.example.com"
  }
}

variable "base_path" {
  description = "Caminho base opcional para o mapeamento (ex.: v1)"
  type        = string
  default     = ""
}

# variables.tf
variable "endpoint_type" {
  description = "Tipo de endpoint do API Gateway (REGIONAL, EDGE ou PRIVATE)"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "EDGE", "PRIVATE"], var.endpoint_type)
    error_message = "O tipo de endpoint deve ser um de: REGIONAL, EDGE, PRIVATE"
  }
}

variable "vpc_endpoint_ids" {
  description = "Lista de IDs de endpoints VPC para APIs privadas"
  type        = list(string)
  default     = []
}

variable "binary_media_types" {
  description = "Lista de tipos de mídia binária suportados pela API"
  type        = list(string)
  default     = ["*/*"]
}

variable "minimum_compression_size" {
  description = "Tamanho mínimo de resposta para compressão (em bytes)"
  type        = number
  default     = null
}

variable "api_parameters" {
  description = "Parâmetros adicionais da API"
  type        = map(string)
  default     = {}
}

variable "openapi_body" {
  description = "Especificação OpenAPI para a API"
  type        = string
  default     = null
}

# variables.tf
variable "logging_level" {
  description = "Nível de logging (OFF, ERROR, INFO)"
  type        = string
  default     = "INFO"
  validation {
    condition     = var.logging_level == null || (var.logging_level != null && can(regex("^(OFF|ERROR|INFO)$", var.logging_level)))
    error_message = "O valor de logging_level deve ser null ou um dos seguintes: OFF, ERROR, INFO."
  }
}

variable "create_log_role" {
  description = "Se deve criar uma role IAM para logging do API Gateway no CloudWatch."
  type        = bool
  default     = true
}