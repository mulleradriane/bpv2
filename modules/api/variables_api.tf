variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Nome da API Gateway REST"
  type        = string
}

variable "description" {
  description = "Descrição da API"
  type        = string
  default     = ""
}

variable "api_key_source" {
  description = "Fonte das API keys (HEADER ou AUTHORIZER)"
  type        = string
  default     = "HEADER"
}

variable "minimum_compression_size" {
  description = "Tamanho mínimo para compressão (bytes)"
  type        = number
  default     = null
}

variable "binary_media_types" {
  description = "Lista de media types binários"
  type        = list(string)
  default     = []  # Default vazio em nao null
}

variable "endpoint_type" {
  description = "Tipo de endpoint (EDGE, REGIONAL, PRIVATE)"
  type        = string
  default     = "REGIONAL"
}

variable "vpc_endpoint_ids" {
  description = "IDs dos VPC endpoints para APIs PRIVATE"
  type        = list(string)
  default     = null
}

variable "manage_account_level_settings" {
  description = "Gerar configurações de nível de conta"
  type        = bool
  default     = false
}

variable "cloudwatch_role_arn" {
  description = "ARN da role do CloudWatch para logging"
  type        = string
  default     = null
}

variable "cloudwatch_role_dependency" {
  description = "Dependency para garantir ordem de criação com a role do CloudWatch"
  type        = any
  default     = null
}

variable "product" {
  description = "Nome do produto/projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, hml, prd)"
  type        = string
}

variable "tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}

variable "custom_policy" {
  description = "Política customizada adicional (opcional)"
  type        = any
  default     = null
}