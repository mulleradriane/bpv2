variable "rest_api_id" {
  type        = string
  description = "ID da REST API"
}

variable "resource_id" {
  type        = string
  description = "ID do recurso"
}

variable "authorization" {
  type        = string
  default     = "NONE"
  description = "Tipo de autorização (NONE, AWS_IAM, COGNITO_USER_POOLS, etc.)"
}

variable "methods" {
  type = map(object({
    integration_type        = string
    uri                     = optional(string)
    integration_http_method = optional(string)
    proxy                   = optional(bool, false)
    connection_type         = optional(string)
    connection_id           = optional(string)
    timeout                 = optional(number, 29000)
    request_parameters = optional(object({
      path   = optional(map(bool), {})
      query  = optional(map(bool), {})
      header = optional(map(bool), {})
    }), {
      path   = {}
      query  = {}
      header = {}
    })
    request_templates = optional(map(string), {})
    request_models    = optional(map(string), {})
    enable_cors       = optional(bool, false)
  }))
  description = "Configuração dos métodos HTTP"
}

variable "method_responses" {
  description = "Responses customizadas por método"
  type = map(map(object({
    response_models     = optional(map(string), {})
    response_templates  = optional(map(string), {})
    response_parameters = optional(map(string), {})
  })))
  default = {}
}

variable "integration_response_selection_patterns" {
  description = "Selection patterns para integration responses por método e status code"
  type        = map(map(string))
  default     = {}
  
  # Exemplo:
  # {
  #   "GET" = {
  #     "404" = ".*NotFound.*"
  #     "500" = ".*Error.*"
  #   }
  #   "POST" = {
  #     "400" = ".*BadRequest.*"
  #   }
  # }
}

variable "request_validators" {
  description = "Validadores de request por método HTTP"
  type        = map(string)
  default     = {}
  
  # Exemplo:
  # {
  #   "POST" = "Validate body and parameters"
  #   "PUT"  = "Validate body"
  # }
}

##############################
# CORS Variables
##############################
variable "cors_allow_headers" {
  type        = string
  default     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  description = "Headers permitidos para CORS"
}

variable "cors_allow_methods" {
  type        = string
  default     = "'GET,POST,PUT,DELETE,OPTIONS'"
  description = "Métodos HTTP permitidos para CORS"
}

variable "cors_allow_origin" {
  type        = string
  default     = "'*'"
  description = "Origins permitidos para CORS"
}

variable "cors_max_age" {
  type        = number
  default     = 7200
  description = "Tempo de cache dos headers CORS em segundos"
}