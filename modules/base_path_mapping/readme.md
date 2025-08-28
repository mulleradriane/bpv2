🛡️ Módulo: Base Path Mapping (modules/base_path_mapping/)

Função
- Gerencia 187+ mapeamentos de domínios customizados.

## Uso Diário

```sh
module "domain_mappings" {
  source = "git::github.com/company/blueprints//modules/base_path_mapping?ref=v2.0.0"
  
  mappings = [
    # API principal no root
    {
      api_id      = module.api.api_id
      stage_name  = "prod"
      domain_name = "api.company.com"
      base_path   = null  # Root mapping
    },
    
    # API versão 1
    {
      api_id      = module.api_v1.api_id
      stage_name  = "prod"
      domain_name = "api.company.com"
      base_path   = "v1"
    },
    
    # Ambiente dev
    {
      api_id      = module.api.api_id
      stage_name  = "dev"
      domain_name = "api.dev.company.com"
      base_path   = null
    }
  ]
}
```