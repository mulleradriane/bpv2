variable "api_id" {
  description = "ID da API REST"
  type        = string
}

variable "stage_name" {
  description = "Nome do stage (ex.: dev, hml, prd)"
  type        = string
}

variable "stage_description" {
  description = "Descrição do stage"
  type        = string
  default     = ""
}

variable "cache_cluster_enabled" {
  description = "Habilitar cache cluster"
  type        = bool
  default     = false
}

variable "cache_cluster_size" {
  description = "Tamanho do cache cluster (0.5, 1.6, 6.1, 13.5, 28.4, 58.2, 118, 237)"
  type        = number
  default     = 0.5
}

variable "xray_tracing_enabled" {
  description = "Habilitar tracing X-Ray"
  type        = bool
  default     = false
}

variable "stage_variables" {
  description = "Variáveis de stage"
  type        = map(string)
  default     = {}
}

variable "access_log_destination_arn" {
  description = "ARN de destino para access logs"
  type        = string
  default     = null
}

variable "access_log_format" {
  description = "Formato dos access logs"
  type        = string
  default     = "json"
}

variable "custom_domain" {
  description = "Domínio customizado para URL de invocação"
  type        = string
  default     = null
}

variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "redeploy_triggers" {
  description = "Triggers para forçar redeployment"
  type        = any
  default     = {}
}

variable "methods_dependency" {
  description = "Dependency para métodos e integrations (evitar race condition)"
  type        = any
  default     = null
}

variable "resources_dependency" {
  description = "Dependency para recursos (evitar race condition)"
  type        = any
  default     = null
}

variable "tags" {
  description = "Tags para o stage"
  type        = map(string)
  default     = {}
}