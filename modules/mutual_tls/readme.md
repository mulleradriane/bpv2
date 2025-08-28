🤝 Módulo: Mutual TLS (modules/mutual_tls/)

Função
- Configura mTLS para 2 domínios específicos com truststore S3.

## Uso Diário

```sh
module "mtls_config" {
  source = "git::github.com/company/blueprints//modules/mutual_tls?ref=v2.0.0"
  
  domains = [
    {
      name              = "secure-api.company.com"
      certificate_arn   = data.aws_acm_certificate.secure.arn
      security_policy   = "TLS_1_2"
      endpoint_type     = "REGIONAL"
      truststore_uri    = "s3://company-truststore/truststore.pem"
      truststore_version = "v2.1.0"
    }
  ]
  
  create_client_policy = true
}
```