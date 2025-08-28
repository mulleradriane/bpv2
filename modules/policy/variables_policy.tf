variable "api_id" {
  description = "ID da API Gateway"
  type        = string
}

variable "policy" {
  description = <<EOT
Mapa representando uma IAM Policy válida.
Exemplo:
{
  Version = "2012-10-17"
  Statement = [
    {
      Effect   = "Allow"
      Action   = "execute-api:Invoke"
      Resource = "*"
      Principal = "*"
      Condition = {
        IpAddress = {
          "aws:SourceIp" = ["203.0.113.0/24"]
        }
      }
    }
  ]
}
EOT
  type = any
}
