variable "role" {
  description = "Papel do grupo (ex.: Apigw)"
  type        = string
}

variable "team" {
  description = "Equipe associada"
  type        = string
}

variable "legacy_name" {
  description = "Nome legado para o grupo"
  type        = string
  default     = null
}

variable "users_to_attachment" {
  description = "Lista de usuários para anexar ao grupo"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags corporativas"
  type        = map(string)
  default     = {}
}