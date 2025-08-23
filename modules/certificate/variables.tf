variable "domain_name" {
  description = "Nome do domínio personalizado (ex.: api.dev.example.com)"
  type        = string
}

variable "certificate_arn" {
  description = "ARN do certificado ACM para o domínio"
  type        = string
  default     = null
}

variable "rest_api_id" {
  description = "ID da API Gateway"
  type        = string
}

variable "stage_name" {
  description = "Nome do stage associado (ex.: dev)"
  type        = string
}

variable "base_path" {
  description = "Caminho base opcional para o mapeamento (ex.: v1)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags corporativas"
  type        = map(string)
  default     = {}
}