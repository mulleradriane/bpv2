provider "aws" {
  region = "us-east-1"
}

# Dados para policies dinâmicas
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Locals para naming e policy vars
locals {
  environment = lower(trimspace(var.environment))
  product     = lower(trimspace(var.product))
  name        = var.legacy_name != null ? trimspace(var.legacy_name) : format("apigw-%s", local.product)
  policy_vars = {
    rest_api_id = module.api.id
    account_id  = data.aws_caller_identity.current.account_id
    region      = data.aws_region.current.id
    allowed_ips = var.default_allowed_ips
    deny_rules  = var.deny_rules
  }

  # Ambientes suportados
  environments = toset(["dev", "hml", "prd"])

  # Statement base com IPs permitidos para API Policy
  base_statement = [
    {
      Effect    = "Allow"
      Principal = "*"
      Action    = "execute-api:Invoke"
      Resource  = "arn:aws:execute-api:${local.policy_vars.region}:${local.policy_vars.account_id}:${local.policy_vars.rest_api_id}/*/*/*"
      Condition = {
        IpAddress = {
          "aws:SourceIp" = local.policy_vars.allowed_ips
        }
      }
    }
  ]

  # Statements de Deny dinâmicos para API Policy
  deny_statements = [
    for k, v in local.policy_vars.deny_rules : {
      Effect    = try(v.Effect, "Deny")
      Principal = try(v.Principal, "*")
      Action    = try(v.Action, "execute-api:Invoke")
      Resource  = try(v.Resource, "arn:aws:execute-api:${local.policy_vars.region}:${local.policy_vars.account_id}:${local.policy_vars.rest_api_id}/*/*/*")
      Condition = try(v.Condition, {})
    }
  ]

  # Policy completa da API Gateway como JSON
  api_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = concat(local.base_statement, local.deny_statements)
  })

  # Policy para a role CI/CD
  ci_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "apigateway:*"
        ]
        Resource = [
          "arn:aws:apigateway:${local.policy_vars.region}::/restapis/${local.policy_vars.rest_api_id}",
          "arn:aws:apigateway:${local.policy_vars.region}::/restapis/${local.policy_vars.rest_api_id}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:PublishVersion",
          "lambda:CreateAlias",
          "lambda:UpdateAlias"
        ]
        Resource = "arn:aws:lambda:${local.policy_vars.region}:${local.policy_vars.account_id}:function:${local.policy_vars.rest_api_id}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::${local.policy_vars.account_id}:role/${local.policy_vars.rest_api_id}-*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${local.policy_vars.region}:${local.policy_vars.account_id}:log-group:/aws/apigateway/${local.policy_vars.rest_api_id}/*:*"
      }
    ]
  })

  # Policy para usuários humanos (legacy)
  user_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["apigateway:*"]
        Resource = [
          "arn:aws:apigateway:${local.policy_vars.region}::/restapis/${local.policy_vars.rest_api_id}",
          "arn:aws:apigateway:${local.policy_vars.region}::/restapis/${local.policy_vars.rest_api_id}/*"
        ]
      }
    ]
  })
}

# Validação temporária para depuração
resource "null_resource" "validate_policy_vars" {
  triggers = {
    allowed_ips = jsonencode(local.policy_vars.allowed_ips)
    deny_rules  = jsonencode(local.policy_vars.deny_rules)
    api_policy  = local.api_policy
    ci_policy   = local.ci_policy
  }
}

##############################
# API Gateway REST API
##############################
module "api" {
  source      = "./modules/api"
  name        = local.name
  description = format("Public API for %s", local.product)
  #tags        = var.tags
}

##############################
# API Gateway Policy
##############################
module "api_policy" {
  source      = "./modules/policy"
  rest_api_id = module.api.id
  policy      = var.custom_api_policy != null ? var.custom_api_policy : local.api_policy
  depends_on  = [module.api]
}

##############################
# IAM para GitLab CI/CD
##############################
module "iam_service" {
  source = "./modules/iam_service"
  name        = "${local.name}-ci-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/gitlab" }
    }]
  })
  policy_json = local.ci_policy
  tags        = var.tags
}

##############################
# Certificados e Domínios por Ambiente
##############################
module "certificate" {
  source            = "./modules/certificate"
  for_each          = local.environments
  domain_name       = lookup(var.default_domain, each.key, "${each.key}.api.example.com")
  certificate_arn   = lookup(var.default_certificates, each.key, null)
  rest_api_id       = module.api.id
  stage_name        = each.key
  base_path         = var.base_path
  depends_on        = [module.api]
}

##############################
# IAM para Usuários Humanos (Legacy, Opcional)
##############################
module "user_group" {
  source = "./modules/user_group"
  count  = var.enable_human_iam ? 1 : 0
  role        = "Apigw"
  team        = local.product
  legacy_name = var.legacy_user_group_name
  users_to_attachment = var.users_to_attachment
  tags        = var.tags
}

module "iam_user_policy" {
  source = "./modules/iam_user_policy"
  count  = var.enable_human_iam ? 1 : 0
  environment = local.environment
  team        = local.product
  product     = local.product
  application = var.application
  ticket      = var.ticket
  blueprint   = var.blueprint
  custom_tags = var.custom_tags
  legacy_name = var.legacy_policy_name
  policy      = local.user_policy
  groups_to_attachment = [module.user_group[0].name]
  depends_on  = [module.user_group]
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
  function_name = format("%s-hello-lambdav2", local.product)
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "${path.module}/hello.zip"
  #tags          = var.tags
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
  path_part   = "{id}"
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
        response_models = { "application/json" = "Empty" }
      },
      "404" = {
        response_models = { "application/json" = "Empty" }
        response_templates = {
          "application/json" = jsonencode({ message = "Not Found", code = 404 })
        }
      }
    }
  }
  integration_response_selection_patterns = {
    GET = { "404" = ".*NotFound.*" }
  }
  cors_allow_methods = "'GET,OPTIONS'"
  cors_allow_origin  = "'https://frontend.acme.com'"
  cors_allow_headers = "'Authorization,Content-Type'"
}

##############################
# Locals para cálculo do hash de deployment
##############################
locals {
  # Primeiro, criamos as strings de configuração para cada método
  hello_method_strings = [
    for method_name, config in module.hello_methods.method_configs : format(
      "%s:%s:%s:%s:%s",
      method_name,
      coalesce(config.integration_type, "none"),
      coalesce(config.uri, "none"),
      config.request_templates != null ? jsonencode(config.request_templates) : "{}",
      config.request_parameters != null ? jsonencode(config.request_parameters) : "{}"
    )
  ]
  
  item_method_strings = [
    for method_name, config in module.item_methods.method_configs : format(
      "%s:%s:%s:%s:%s",
      method_name,
      coalesce(config.integration_type, "none"),
      coalesce(config.uri, "none"),
      config.request_templates != null ? jsonencode(config.request_templates) : "{}",
      config.request_parameters != null ? jsonencode(config.request_parameters) : "{}"
    )
  ]
  
  # Concatenamos e ordenamos as strings
  all_method_configs = sort(concat(
    local.hello_method_strings,
    local.item_method_strings
  ))
  
  all_configs = {
    methods = local.all_method_configs
    validators = concat(
      values(module.hello_methods.request_validators),
      values(module.item_methods.request_validators)
    )
    stage_variables = {
      environment = var.environment
      version     = "v2"
    }
  }
  
  methods_hash = sha256(jsonencode(local.all_configs))
}

##############################
# CloudWatch Log Group para logs de acesso da API Gateway
##############################
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${module.api.id}"
  retention_in_days = 30
  tags              = var.tags
}

##############################
# Deployment por Ambiente
##############################
module "deployment" {
  source                 = "./modules/deployment"
  for_each               = local.environments
  rest_api_id            = module.api.id
  stage_name             = each.key
  triggers_sha           = local.methods_hash
  deployment_description = "Deployment para ${each.key}"
  stage_variables        = { environment = each.key, version = "v2" }
  tags                   = var.tags
  log_group_arn          = aws_cloudwatch_log_group.api_gateway_logs.arn
  depends_on             = [module.hello_methods, module.item_methods]
}