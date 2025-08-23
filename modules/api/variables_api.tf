variable "name" {
  type        = string
  description = "Nome da API"
}

variable "description" {
  type        = string
  default     = "API criada via blueprint"
}

variable "stage_name" {
  type        = string
  default     = "dev"
}

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

# Tipos de mídia binária, compressão e parâmetros adicionais
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