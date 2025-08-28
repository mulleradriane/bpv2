variable "mappings" {
  description = "Lista de mapeamentos base path para criar"
  type = list(object({
    key         = string        # Chave única para o mapping
    api_id      = string        # ID da API Gateway
    stage_name  = string        # Nome do stage
    domain_name = string        # Nome do domínio customizado
    base_path   = optional(string) # Base path (opcional - para root usar null)
  }))
  validation {
    condition = length(var.mappings) > 0
    error_message = "At least one mapping must be specified."
  }
}

variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags adicionais para os resources"
  type        = map(string)
  default     = {}
}