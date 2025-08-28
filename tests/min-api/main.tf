# tests/min-api/main.tf

terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# module "api" {
#   source = "../../modules/api"

#   name        = "smoke-test-api"
#   description = "API de teste para validação da blueprint"
#   endpoint_type = "REGIONAL" # Padrão corporativo
#   product     = "smoketest"
#   environment = "dev"
# }

# module "root_resource" {
#   source = "../../modules/resource"

#   api_id           = module.api.api_id
#   root_resource_id = module.api.root_resource_id

#   resources = {
#     ping = {
#       path_part = "ping"
#       parent_id = module.api.root_resource_id
#     }
#   }
# }

# module "ping_method" {
#   source = "../../modules/method"
#   api_id = module.api.api_id
#   region = var.region
#   api_execution_arn = module.api.execution_arn

#   methods = {
#     GET_ping = {
#       resource_id       = module.root_resource.resource_ids["ping"]
#       http_method       = "GET"
#       authorization     = "NONE"
#       api_key_required  = false
#       integration_type  = "MOCK"
      
#       # CRÍTICO: Request template para MOCK
#       request_templates = {
#         "application/json" = jsonencode({
#           statusCode = 200
#         })
#       }
      
#       # Configurações de response para MOCK
#       method_responses = {
#         "200" = {
#           response_models = {
#             "application/json" = "Empty"
#           }
#         }
#       }
      
#       integration_responses = {
#         "200" = {
#           response_templates = {
#             "application/json" = "{\"statusCode\": 200, \"message\": \"pong\"}"
#           }
#           # Adicionar pattern de seleção
#           selection_pattern = "200"
#         }
#       }
#     }
#   }
# }
# module "deployment" {
#   source = "../../modules/deployment"

#   api_id          = module.api.api_id
#   stage_name      = "dev"
#   stage_variables = {
#     deployed_at = timestamp()
#   }

#   redeploy_triggers = {
#     api_id    = module.api.api_id
#     methods   = module.ping_method.methods_hash
#     resources = module.root_resource.resources_hash
#   }

#   #  Dependências críticas para evitar race condition
#   methods_dependency   = module.ping_method.integrations
#   resources_dependency = module.root_resource.resource_ids

#   tags = {
#     TestType = "smoke"
#   }
# }

# module "custom_domain" {
#   source = "../../modules/custom_domain"

#   domain_name     = "test-api-${random_id.test.hex}.example.com"  # Domínio de mentira
#   certificate_arn = aws_acm_certificate.test.arn  # Certificado de teste
#   endpoint_type   = "REGIONAL"
#   security_policy = "TLS_1_2"
  
#   # Não criar record Route53 para teste
#   create_route53_record = false
# }

# # Certificado de teste (validação por email para não precisar de DNS)
# resource "aws_acm_certificate" "test" {
#   domain_name       = "test-api-${random_id.test.hex}.example.com"
#   validation_method = "EMAIL"  # Para teste, não precisa de DNS

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "random_id" "test" {
#   byte_length = 4
# }


# Exemplo de uso real com múltiplos mappings
module "base_path_mapping" {
  source = "../../modules/base_path_mapping"

  mappings = [
    # Mapeamentos root (6 domínios sem root mapping)
    {
      key         = "app1-root"
      api_id      = "abc123"
      stage_name  = "prod"
      domain_name = "api.app1.com"
      base_path   = null
    },
    
    # Mapeamentos com base paths (181 mappings)
    {
      key         = "app2-v1"
      api_id      = "def456" 
      stage_name  = "prod"
      domain_name = "api.app2.com"
      base_path   = "v1"
    },
    {
      key         = "app3-v2"
      api_id      = "ghi789",
      stage_name  = "prod",
      domain_name = "api.app3.com",
      base_path   = "v2"
    }
    # ... até 187 mapeamentos dos apigw reais
  ]
}