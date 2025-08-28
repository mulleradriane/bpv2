🔒 Módulo: TLS Policy (modules/tls_policy/)

Função
- Força TLS 1.2+ e migra 63 domínios de TLS 1.0.

## Uso Diário

```sh
module "tls_upgrade" {
  source = "git::github.com/company/blueprints//modules/tls_policy?ref=v2.0.0"
  
  domains = [
    {
      name            = "api.payments.com"
      certificate_arn = data.aws_acm_certificate.payments.arn
      security_policy = "TLS_1_2"  # Upgrade obrigatório
      endpoint_type   = "REGIONAL"
    }
  ]
  
  create_enforcement_policy = true
}
```