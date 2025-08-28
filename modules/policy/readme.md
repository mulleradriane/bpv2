🛡️ Módulo: Policy (modules/policy/)

Função
- Políticas de segurança e acesso para APIs.

## Uso Diário

```sh
module "api_policy" {
  source = "git::github.com/company/blueprints//modules/policy?ref=v2.0.0"
  
  api_id = module.api.api_id
  
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "execute-api:Invoke"
        Resource  = "${module.api.api_id}/*"
        Condition = {
          IpAddress = {
            "aws:SourceIp" = ["10.0.0.0/8", "192.168.0.0/16"]
          }
        }
      }
    ]
  }
}
```