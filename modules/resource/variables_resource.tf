variable "api_id" {
  description = "ID da API Gateway REST"
  type        = string
}

variable "root_resource_id" {
  description = "ID do recurso raiz da API (/) - usado quando não há parent_id explícito"
  type        = string
}

variable "resources" {
  description = <<EOT
Mapa de recursos do API Gateway.
Chave = nome lógico do recurso.
Exemplo:
{
  users = {
    path_part = "users"
    parent_id = null
  }
  user_id = {
    path_part = "{id}"
    parent_id = aws_api_gateway_resource.this["users"].id
  }
}
EOT
  type = map(object({
    path_part = string
    parent_id = optional(string)
  }))
}
