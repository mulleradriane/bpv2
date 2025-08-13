provider "aws" {
  region = "us-east-1"
}

##############################
# API Gateway REST API
##############################
module "api" {
  source      = "./modules/api"
  name        = "meu-projeto-apiv2"
  description = "API de exemplo com blueprint"
  stage_name  = "dev"
}

##############################
# Recurso: /hello
##############################
module "hello_resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "hello"
}

##############################
# Lambda Function: Hello
##############################
module "lambda_hello" {
  source        = "./modules/lambda"
  function_name = "hello-lambdav2"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "${path.module}/hello.zip"
}

module "hello_methods" {
  source        = "./modules/method"
  rest_api_id   = module.api.id
  resource_id   = module.hello_resource.id
  authorization = "NONE"

  methods = {
    "GET" = {
      integration_type        = "AWS_PROXY"
      uri                     = module.lambda_hello.uri
      integration_http_method = "POST"
      enable_cors             = false
    },
    "OPTIONS" = {
      integration_type = "MOCK"
      enable_cors      = true
    },
    "POST" = {
      integration_type        = "HTTP"
      uri                     = "https://httpbin.org/post"
      integration_http_method = "POST"
      enable_cors             = true

      request_models = {
        "application/json" = "Empty"
      }
    }
  }

  request_validators = {
    "POST" = "Validate body and parameters"
  }

  cors_allow_methods = "'GET,POST,OPTIONS'"
  cors_allow_origin  = "'*'"
  cors_allow_headers = "'Authorization,Content-Type'"
}

##############################
# Recurso: /items/{id}
##############################
module "item_resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "items"
}

module "item_id_resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.item_resource.id
  path_part   = "{id}" # ← path param
}

module "item_methods" {
  source        = "./modules/method"
  rest_api_id   = module.api.id
  resource_id   = module.item_id_resource.id
  authorization = "NONE"

  methods = {
    "GET" = {
      integration_type        = "HTTP"
      uri                     = "https://httpbin.org/status/404"
      integration_http_method = "GET"
      enable_cors             = true

      request_parameters = {
        path   = { id = true }
        query  = {}
        header = {}
      }

      request_templates = {
        "application/json" = <<EOF
{
  "requestedId": "$input.params('id')"
}
EOF
      }
    },
    "OPTIONS" = {
      integration_type = "MOCK"
      enable_cors      = true
    }
  }

  method_responses = {
    GET = {
      "200" = {
        response_models = {
          "application/json" = "Empty"
        }
      },
      "404" = {
        response_models = {
          "application/json" = "Empty"
        }
        response_templates = {
          "application/json" = jsonencode({
            message = "Not Found",
            code    = 404
          })
        }
      }
    }
  }

  integration_response_selection_patterns = {
    GET = {
      "404" = ".*NotFound.*"
    }
  }

  cors_allow_methods = "'GET,OPTIONS'"
  cors_allow_origin  = "'https://frontend.acme.com'"
  cors_allow_headers = "'Authorization,Content-Type'"
}

##############################
# Locals para cálculo do hash de deployment
##############################
locals {
  # Coleta configurações relevantes para métodos
  all_method_configs = sort(concat(
    [
      for method_name, config in module.hello_methods.method_configs : "${method_name}:${config.integration_type}:${try(config.uri, "")}:${try(jsonencode(config.request_templates), "")}:${try(jsonencode(config.request_parameters), "")}"
    ],
    [
      for method_name, config in module.item_methods.method_configs : "${method_name}:${config.integration_type}:${try(config.uri, "")}:${try(jsonencode(config.request_templates), "")}:${try(jsonencode(config.request_parameters), "")}"
    ]
  ))

  # Coleta validadores e stage variables
  all_configs = {
    methods = local.all_method_configs
    validators = concat(
      values(module.hello_methods.request_validators),
      values(module.item_methods.request_validators)
    )
    stage_variables = module.deployment.stage_variables
  }

  # Gera hash baseado nas configurações relevantes
  methods_hash = sha256(jsonencode(local.all_configs))
}

##############################
# Deployment Automático
##############################
module "deployment" {
  source = "./modules/deployment"

  rest_api_id            = module.api.id
  stage_name             = "dev"
  triggers_sha           = local.methods_hash
  deployment_description = "Atualização automática da API com métodos e validações"

  # Stage variables (opcional)
  stage_variables = {
    environment  = "dev"
    version      = "v2"
    lambda_alias = "dev"
  }

  # Configurações de throttling (opcional)
  throttle_settings = {
    rate_limit  = 1000
    burst_limit = 2000
  }

  # Configurações de cache (opcional)
  cache_cluster_enabled = false
  cache_cluster_size    = "0.5"

  # Tags
  tags = {
    Environment = "dev"
    Project     = "meu-projeto-apiv2"
    ManagedBy   = "terraform"
  }

  # Dependências explícitas para garantir ordem de criação
  depends_on = [
    module.hello_methods,
    module.item_methods
  ]
}

##############################
# Outputs principais
##############################
output "api_id" {
  description = "ID da API Gateway REST"
  value       = module.api.id
}

output "api_root_resource_id" {
  description = "ID do recurso raiz da API"
  value       = module.api.root_resource_id
}

output "deployment_id" {
  description = "ID do deployment atual"
  value       = module.deployment.deployment_id
}

output "stage_name" {
  description = "Nome do stage"
  value       = module.deployment.stage_name
}

output "invoke_url" {
  description = "URL de invocação da API"
  value       = module.deployment.invoke_url
}

output "stage_arn" {
  description = "ARN do stage"
  value       = module.deployment.stage_arn
}

output "methods_hash" {
  description = "Hash atual dos métodos (para debug)"
  value       = local.methods_hash
}