🚀 Módulo: Deployment (modules/deployment/)

Função
- Gerencia deployments e múltiplos stages (dev, hml, prod).

## Uso Diário

```sh
module "deployment" {
  source = "git::github.com/company/blueprints//modules/deployment?ref=v2.0.0"
  
  api_id    = module.api.api_id
  stages    = ["dev", "hml", "staging", "prod"]
  
  stage_configs = {
    dev = { cache_enabled = false, xray_enabled = false }
    hml = { cache_enabled = true, cache_size = 0.5 }
    prod = { cache_enabled = true, cache_size = 1.6, xray_enabled = true }
  }
  
  global_variables = {
    API_VERSION = "v1.0"
    DEPLOYED_AT = timestamp()
  }
}
```