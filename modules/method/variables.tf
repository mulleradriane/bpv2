variable "api_id" {
  description = "ID da API REST"
  type        = string
}

variable "region" {
  description = "Região AWS para construção de ARNs"
  type        = string
  default     = "us-east-1"
}

variable "methods" {
  description = "Mapa de métodos para criar"
  type = map(object({
    resource_id                = string
    http_method                = string
    authorization              = optional(string, "NONE")
    authorizer_id              = optional(string)
    api_key_required           = optional(bool, false)
    request_parameters         = optional(map(bool), {})
    request_models             = optional(map(string), {})
    request_validator_id       = optional(string)
    integration_type           = optional(string, "MOCK")
    integration_http_method    = optional(string)
    integration_uri            = optional(string)
    lambda_arn                 = optional(string)
    connection_type            = optional(string)
    connection_id              = optional(string)
    credentials                = optional(string)
    passthrough_behavior       = optional(string, "WHEN_NO_MATCH")
    timeout_milliseconds       = optional(number, 29000)
    cache_key_parameters       = optional(list(string), [])
    cache_namespace            = optional(string)
    content_handling           = optional(string)
    tls_config                 = optional(object({
      insecure_skip_verification = optional(bool, false)
    }))
    request_templates          = optional(map(string), {})
    method_responses           = optional(map(object({
      response_models     = optional(map(string), {})
      response_parameters = optional(map(bool), {})
    })), {})
    integration_responses      = optional(map(object({
      response_templates  = optional(map(string), {})
      response_parameters = optional(map(string), {})
      selection_pattern   = optional(string)
    })), {})
  }))
}

variable "api_execution_arn" {
  description = "Execution ARN da API para políticas Lambda"
  type        = string
}