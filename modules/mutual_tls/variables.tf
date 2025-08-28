variable "domains" {
  description = "Lista de domínios para configurar mTLS"
  type = list(object({
    name              = string
    certificate_arn   = string
    security_policy   = string
    endpoint_type     = string
    truststore_uri    = string
    truststore_version = optional(string)
    environment       = optional(string, "prod")
    tags              = optional(map(string), {})
  }))
}

variable "create_truststore_bucket" {
  description = "Criar bucket S3 para truststore"
  type        = bool
  default     = false
}

variable "truststore_bucket_name" {
  description = "Nome do bucket S3 para truststore"
  type        = string
  default     = null
}

variable "existing_truststore_bucket" {
  description = "Bucket S3 existente para truststore"
  type        = string
  default     = null
}

variable "truststore_file_path" {
  description = "Caminho local do arquivo truststore para upload"
  type        = string
  default     = null
}

variable "truststore_file_name" {
  description = "Nome do arquivo truststore no S3"
  type        = string
  default     = "truststore.pem"
}

variable "create_client_policy" {
  description = "Criar política IAM para clientes mTLS"
  type        = bool
  default     = false
}

variable "client_policy_name" {
  description = "Nome da política IAM para clientes mTLS"
  type        = string
  default     = "APIGateway-mTLS-Client-Policy"
}

variable "tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
  default     = {}
}