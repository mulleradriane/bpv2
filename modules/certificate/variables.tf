variable "domain_name" {
  description = "Nome de domínio principal para o certificado"
  type        = string
}

variable "validation_method" {
  description = "Método de validação (DNS, EMAIL, NONE)"
  type        = string
  default     = "DNS"
}

variable "san_names" {
  description = "Nomes alternativos de sujeito (Subject Alternative Names)"
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "ID da zona Route53 para validação DNS"
  type        = string
  default     = null
}

variable "certificate_transparency_logging" {
  description = "Habilitar logging de transparência de certificado"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags para o certificado"
  type        = map(string)
  default     = {}
}