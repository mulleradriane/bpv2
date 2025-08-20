variable "rest_api_id" {
  type        = string
  description = "ID da API onde o recurso será criado"
}

variable "parent_id" {
  type        = string
  description = "ID do recurso pai (normalmente o root)"
}

variable "path_part" {
  type        = string
  description = "Segmento do caminho do recurso (ex: 'hello')"
}
