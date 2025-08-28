Usabilidade pelo repositorio da pipeline


## Uso pelo time:


```sh
module "payments_api" {
  source = "git::https://github.com/company/blueprints.git//modules/api_gateway?ref=v1.2.0"

  api_name    = "payments"
  environment = "dev"
  base_path   = "v1/payments"
  
  resources = {
    transactions = {
      path_part = "transactions"
    }
    refunds = {
      path_part = "refunds"
      parent_id = "transactions"  # Hierarquia automática
    }
  }
}

output "payments_api_url" {
  value = module.payments_api.api_url
}

```

## Para Ambientes com Configurações Específicas:

```sh
locals {
  environment_configs = {
    dev = {
      minimum_compression_size = 0      # Desabilita compressão em dev
      cache_cluster_enabled    = false  # Desabilita cache em dev
    }
    hml = {
      minimum_compression_size = 1024
      cache_cluster_enabled    = true
      cache_cluster_size       = 0.5
    }
    prd = {
      minimum_compression_size = 2048
      cache_cluster_enabled    = true
      cache_cluster_size       = 1.6
      xray_tracing_enabled     = true
    }
  }
  
  current_config = local.environment_configs[var.environment]
}

# Aplica configurações específicas por environment
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.api_name}-${var.environment}"
  description = var.description

  minimum_compression_size = local.current_config.minimum_compression_size
  # ... outras configs ...
}
```