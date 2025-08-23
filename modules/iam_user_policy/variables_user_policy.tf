variable "environment" {
  description = "Ambiente da política"
  type        = string
}

variable "team" {
  description = "Equipe associada"
  type        = string
}

variable "product" {
  description = "Produto associado"
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
  description = "Nome legado para a política"
  type        = string
  default     = null
}

variable "policy" {
  description = "Política JSON"
  type        = string
}

variable "groups_to_attachment" {
  description = "Lista de grupos para anexar a política"
  type        = list(string)
}