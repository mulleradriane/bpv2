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

