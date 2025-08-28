variable "region" {
  description = "Região AWS onde o domínio será criado"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Nome de domínio customizado (ex: api.example.com)"
  type        = string
}

variable "certificate_arn" {
  description = "ARN do certificado ACM válido para o domínio"
  type        = string
}

variable "endpoint_type" {
  description = "Tipo de endpoint (REGIONAL ou EDGE)"
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "EDGE"], var.endpoint_type)
    error_message = "Endpoint type must be either REGIONAL or EDGE."
  }
}

variable "security_policy" {
  description = "Política de segurança TLS (TLS_1_0, TLS_1_2)"
  type        = string
  default     = "TLS_1_2"
  validation {
    condition     = contains(["TLS_1_0", "TLS_1_2"], var.security_policy)
    error_message = "Security policy must be either TLS_1_0 or TLS_1_2."
  }
}

variable "mutual_tls_truststore_uri" {
  description = "URI do truststore S3 para mTLS (ex: s3://bucket-name/truststore.pem)"
  type        = string
  default     = null
}

variable "mutual_tls_truststore_version" {
  description = "Versão do objeto truststore no S3 (opcional)"
  type        = string
  default     = null
}

variable "route53_zone_id" {
  description = "ID da zona Route53 para criar record (opcional)"
  type        = string
  default     = null
}

variable "create_route53_record" {
  description = "Criar record Route53 automaticamente"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Ambiente (dev, hml, prd)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags adicionais para o domain name"
  type        = map(string)
  default     = {}
}