🏷️ Módulo: API 

Função

Cria API Gateway REST base com configurações corporativas padrão.


## Uso Diário

```sh
module "api" {
  source = "git::github.com/company/blueprints//modules/api?ref=v2.0.0"
  
  name        = "meu-servico"
  description = "API de serviço corporativo"
  environment = "dev"  # dev, hml, prd
  endpoint_type = "REGIONAL"
  
  # Configurações automáticas
  binary_media_types = ["image/jpeg", "application/pdf"]
}
```

## Outputs Úteis

```sh
api_id          = "abc123def"
root_resource_id = "xyz456"
execution_arn   = "arn:aws:execute-api:us-east-1:123456789012:abc123def"
```


# API com IPs adicionais específicos

```sh
module "api_com_ip_extra" {
  source = "git::github.com/company/blueprints//modules/api?ref=v2.0.0"
  
  name        = "api-com-ip-extra"
  environment = "prod"
  
  custom_policy = {
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "arn:aws:execute-api:us-east-1:123456789012:${module.api_com_ip_extra.api_id}/*/*/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = [
              "203.0.113.10/32",  # IP específico desta API
              "198.51.100.0/24"   # Range específico
            ]
          }
        }
      }
    ]
  }
}
```


# API com políticas complexas + IPs corporativos

```sh
module "api_complexa" {
  source = "git::github.com/company/blueprints//modules/api?ref=v2.0.0"
  
  name        = "api-complexa"
  environment = "prod"
  
  custom_policy = {
    Statement = [
      # IPs específicos
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "arn:aws:execute-api:us-east-1:123456789012:${module.api_complexa.api_id}/*/*/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = ["203.0.113.10/32"]
          }
        }
      },
      # Outras condições caso existir (ex: IAM)
      {
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:role/LambdaExecutionRole"
        }
        Action    = "execute-api:Invoke"
        Resource  = "arn:aws:execute-api:us-east-1:123456789012:${module.api_complexa.api_id}/prod/POST/users"
      }
    ]
  }
}
```
