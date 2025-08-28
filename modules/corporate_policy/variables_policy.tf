# modules/corporate_policy/variables.tf
variable "rest_api_id" {
  description = "ID da API Gateway"
  type        = string
}

variable "region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "mandatory_ips" {
  description = "Lista de IPs corporativos OBRIGATÓRIOS"
  type        = list(string)
  default     = [
    "100.87.140.109/32",
    "200.231.117.105/32",
    "4004.165.27.224/32",
    "100.1.15.220/32",
    "200.245.207.0/24"
  ]
}

variable "custom_policy" {
  description = "Política customizada adicional (opcional)"
  type        = any
  default     = null
}