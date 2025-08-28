📁 Blueprint: AWS API Gateway Enterprise

📋 Visão Geral

Blueprint Terraform para gerenciamento de API Gateway em escala corporativa com:
    
- 100+ APIs Gateway simultâneas
- 500+ rotas por API
- 84 domínios customizados
- 187 base path mappings
- Suporte a TLS 1.2+ e mTLS

```sh
company-blueprints/
├── modules/
│   ├── api/                    # API Gateway REST base
│   ├── resource/               # Recursos e endpoints
│   ├── method/                 # Métodos HTTP e integrações
│   ├── deployment/             # Deployments e stages
│   ├── policy/                 # Políticas de segurança
│   ├── base_path_mapping/      # Domínios customizados
│   ├── tls_policy/             # Enforcement TLS 1.2+
│   └── mutual_tls/             # Autenticação mútua TLS
└── examples/
    └── production-ready/       # Exemplos
```


🚀 Guia Completo: Criando Recursos com CORS, Proxy e Todas as Integrações

📖 Índice

- [Criando Resource com CORS](#criando-resource-com-cors)
- [Método POST com Lambda](#método-post-com-lambda)
- [Método POST com HTTP](#método-post-com-http)
- [Método POST com Mock](#método-post-com-mock)
- [Método POST com AWS Service](#método-post-com-aws-service)
- [Método POST com VPC Link](#método-post-com-vpc-link)
- [Configurações Avançadas](#configurações-avançadas)

---

## Criando Resource com CORS

```sh
# modules/api_gateway_with_cors/main.tf
module "api_com_cors" {
  source = "github.com/company/blueprints//modules/api_gateway?ref=v2.0.0"
  
  name        = "api-com-cors"
  environment = "dev"
  
  resources = {
    # Resource principal com CORS
    produtos = {
      path_part = "produtos"
      cors = {
        allow_headers = ["Content-Type", "Authorization", "X-Amz-Date"]
        allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
        allow_origin  = "https://meuapp.company.com"
        max_age       = 3600
      }
    }
    
    # Sub-recurso também com CORS
    produto_id = {
      path_part = "{id}"
      parent_id = "produtos"
      cors = {
        allow_origin = "*"  # Libera qualquer origem
        allow_methods = ["GET", "PUT", "DELETE"]
      }
    }
  }
}
```

## Método POST com Lambda

```sh
# metodo_post_lambda.tf
module "post_lambda" {
  source = "github.com/company/blueprints//modules/method?ref=v2.0.0"
  
  api_id = module.api_com_cors.api_id
  region = "us-east-1"
  
  methods = {
    POST_produtos = {
      resource_id = module.api_com_cors.resource_ids["produtos"]
      http_method = "POST"
      authorization = "AWS_IAM"  # Ou "NONE", "CUSTOM", "COGNITO"
      
      # 🔥 INTEGRAÇÃO LAMBDA (Lambda Proxy Integration)
      integration_type        = "AWS_PROXY"
      lambda_arn             = "arn:aws:lambda:us-east-1:123456789012:function:criar-produto"
      integration_http_method = "POST"
      
      # 📝 REQUEST CONFIG (Method Request)
      request_parameters = {
        "method.request.header.Authorization" = true
        "method.request.querystring.categoria" = true
      }
      
      request_models = {
        "application/json" = "Empty"
      }
      
      # 🎯 RESPONSE CONFIG (Method Response)
      method_responses = {
        "201" = {
          response_models = {
            "application/json" = "Empty"
          }
          response_parameters = {
            "method.response.header.Location" = true
          }
        }
        "400" = {
          response_models = {
            "application/json" = "Error"
          }
        }
      }
    }
  }
}
```

## Método POST com HTTP

```sh
# metodo_post_http.tf
module "post_http" {
  source = "github.com/company/blueprints//modules/method?ref=v2.0.0"
  
  api_id = module.api_com_cors.api_id
  region = "us-east-1"
  
  methods = {
    POST_produtos_http = {
      resource_id = module.api_com_cors.resource_ids["produtos"]
      http_method = "POST"
      authorization = "NONE"
      
      # 🔥 INTEGRAÇÃO HTTP (HTTP Proxy)
      integration_type        = "HTTP_PROXY"
      integration_http_method = "POST"
      integration_uri         = "https://api.externa.com/produtos"
      
      # ⚙️ HTTP CONFIG
      connection_type = "INTERNET"  # Ou VPC_LINK
      timeout_milliseconds = 29000  # 29s máximo
      
      # 🔐 SEGURANÇA
      tls_config = {
        insecure_skip_verification = false  # Valida certificado SSL
      }
      
      # 📊 CACHE
      cache_key_parameters = ["method.request.querystring.categoria"]
      cache_namespace      = "produtos"
      
      # 🎨 CONTENT HANDLING
      content_handling = "CONVERT_TO_TEXT"  # Ou CONVERT_TO_BINARY
      
      # 📝 REQUEST TEMPLATES (Velocity Templates)
      request_templates = {
        "application/json" = jsonencode({
          "categoria" : "$input.params('categoria')",
          "corpo" : $input.json('$')
        })
      }
      
      # 🎯 INTEGRATION RESPONSES
      integration_responses = {
        "200" = {
          response_templates = {
            "application/json" = "{\"status\": \"success\", \"data\": $input.json('$')}"
          }
          selection_pattern = "2\\d{2}"  # Regex para status 200-299
        }
        "500" = {
          response_templates = {
            "application/json" = "{\"error\": \"Erro no servidor externo\"}"
          }
        }
      }
    }
  }
}
```

## Método POST com Mock

```sh
# metodo_post_mock.tf
module "post_mock" {
  source = "github.com/company/blueprints//modules/method?ref=v2.0.0"
  
  api_id = module.api_com_cors.api_id
  region = "us-east-1"
  
  methods = {
    POST_produtos_mock = {
      resource_id = module.api_com_cors.resource_ids["produtos"]
      http_method = "POST"
      authorization = "NONE"
      
      # 🔥 INTEGRAÇÃO MOCK (Para testes)
      integration_type = "MOCK"
      
      # 📝 REQUEST TEMPLATE
      request_templates = {
        "application/json" = jsonencode({
          "statusCode" = 201
        })
      }
      
      # 🎯 RESPONSE CONFIG
      method_responses = {
        "201" = {
          response_models = {
            "application/json" = "Empty"
          }
        }
      }
      
      integration_responses = {
        "201" = {
          response_templates = {
            "application/json" = jsonencode({
              "id" = "12345",
              "nome" = "Produto Mock",
              "criadoEm" = "2024-01-01T00:00:00Z"
            })
          }
        }
      }
    }
  }
}
```

## Método POST com AWS Service

```sh
# metodo_post_aws_service.tf
module "post_aws_service" {
  source = "github.com/company/blueprints//modules/method?ref=v2.0.0"
  
  api_id = module.api_com_cors.api_id
  region = "us-east-1"
  
  methods = {
    POST_s3_upload = {
      resource_id = module.api_com_cors.resource_ids["produtos"]
      http_method = "POST"
      authorization = "AWS_IAM"
      
      # 🔥 INTEGRAÇÃO AWS SERVICE
      integration_type        = "AWS"
      integration_http_method = "POST"
      integration_uri         = "arn:aws:apigateway:us-east-1:s3:action/PutObject"
      
      # 🪪 CREDENCIAIS
      credentials = "arn:aws:iam::123456789012:role/APIGateway-S3-Access"
      
      # 📦 REQUEST PARAMETERS
      request_parameters = {
        "integration.request.header.Content-Type" = "method.request.header.Content-Type"
        "integration.request.path.bucket"         = "method.request.querystring.bucket"
        "integration.request.path.key"            = "method.request.querystring.key"
      }
      
      # 🎯 RESPONSE CONFIG
      integration_responses = {
        "200" = {
          response_templates = {
            "application/json" = "{\"message\": \"Arquivo salvo com sucesso\"}"
          }
        }
      }
    }
  }
}
```

## Método POST com VPC Link

```sh
# metodo_post_vpc_link.tf
module "post_vpc_link" {
  source = "github.com/company/blueprints//modules/method?ref=v2.0.0"
  
  api_id = module.api_com_cors.api_id
  region = "us-east-1"
  
  methods = {
    POST_interno = {
      resource_id = module.api_com_cors.resource_ids["produtos"]
      http_method = "POST"
      authorization = "NONE"
      
      # 🔥 INTEGRAÇÃO VPC LINK
      integration_type        = "HTTP"
      integration_http_method = "POST"
      integration_uri         = "http://internal-api.private:8080/produtos"
      connection_type         = "VPC_LINK"
      connection_id           = "arn:aws:apigateway:us-east-1:vpc-link/abc123"
      
      # ⚡ TIMEOUT CONFIG
      timeout_milliseconds = 10000  # 10s para APIs internas
      
      # 🔐 SEGURANÇA
      tls_config = {
        insecure_skip_verification = true  # Para certificados self-signed
      }
    }
  }
}
```

## Configurações Avançadas

```sh
request_parameters = {
  # URL Query String Parameters
  "method.request.querystring.categoria"  = true
  "method.request.querystring.pagina"     = true
  "method.request.querystring.limite"     = true
  
  # HTTP Headers
  "method.request.header.Authorization"   = true
  "method.request.header.Content-Type"    = true
  "method.request.header.X-Correlation-Id" = true
  
  # Path Parameters
  "method.request.path.id"                = true
}
```



🎭 Request Models

```sh
request_models = {
  "application/json" = "ProdutoRequest"
  "application/xml"  = "ProdutoXMLRequest"
}

# Definindo os modelos
resource "aws_api_gateway_model" "produto_request" {
  rest_api_id  = module.api_com_cors.api_id
  name         = "ProdutoRequest"
  description  = "Modelo de request para criação de produto"
  content_type = "application/json"
  
  schema = jsonencode({
    type = "object"
    required = ["nome", "preco"]
    properties = {
      nome = { type = "string", minLength = 1, maxLength = 100 }
      preco = { type = "number", minimum = 0 }
      categoria = { type = "string" }
    }
  })
}
```



⏰ Timeout e Retry

```sh
timeout_milliseconds = 15000  # 15 segundos

# Com retry configuration (usando customização avançada)
passthrough_behavior = "WHEN_NO_MATCH"  # Ou WHEN_NO_TEMPLATES, NEVER
```


🔐 Autenticação Avançada

```sh
authorization = "CUSTOM"
authorizer_id = module.custom_authorizer.authorizer_id

# Scopes para OAuth
authorization_scopes = ["produtos.criar", "produtos.ler"]
```

----

🚀 Como Usar - Passo a Passo

## Escolha o Tipo de Integração

```sh
# Lambda → integration_type = "AWS_PROXY"
# HTTP   → integration_type = "HTTP_PROXY" 
# Mock   → integration_type = "MOCK"
# AWS    → integration_type = "AWS"
# VPC    → integration_type = "HTTP" + connection_type = "VPC_LINK"
```

## Configure o Método HTTP

```sh
http_method = "POST"  # GET, POST, PUT, DELETE, PATCH, etc.
```

## Defina a Autenticação

```sh
authorization = "NONE"       # Público
authorization = "AWS_IAM"    # IAM Users/Roles  
authorization = "COGNITO"    # Cognito User Pools
authorization = "CUSTOM"     # Custom Authorizer
```

## Configure a Integração

```sh
# Para HTTP:
integration_uri = "https://api.externa.com/endpoint"

# Para Lambda:
lambda_arn = "arn:aws:lambda:region:account:function:name"

# Para AWS Service:
integration_uri = "arn:aws:apigateway:region:service:action"
```

## Adicione Configurações Específicas

```sh
# Timeout
timeout_milliseconds = 30000

# Cache
cache_key_parameters = ["method.request.querystring.pagina"]

# TLS
tls_config = { insecure_skip_verification = false }
```





## Exemplo Completo

```sh
module "api_produtos" {
  source = "github.com/company/blueprints//modules/api_gateway?ref=v2.0.0"
  
  name        = "produtos"
  environment = "dev"
  
  resources = {
    produtos = {
      path_part = "produtos"
      cors = {
        allow_origin  = "*"
        allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
      }
    }
    produto_id = {
      path_part = "{id}"
      parent_id = "produtos"
    }
  }
}

module "metodos_produtos" {
  source = "github.com/company/blueprints//modules/method?ref=v2.0.0"
  
  api_id = module.api_produtos.api_id
  region = "us-east-1"
  
  methods = {
    # POST - Criar produto (Lambda)
    POST_produtos = {
      resource_id      = module.api_produtos.resource_ids["produtos"]
      http_method      = "POST"
      authorization    = "AWS_IAM"
      integration_type = "AWS_PROXY"
      lambda_arn       = "arn:aws:lambda:us-east-1:123456789012:function:criar-produto"
    }
    
    # GET - Listar produtos (HTTP)
    GET_produtos = {
      resource_id              = module.api_produtos.resource_ids["produtos"]
      http_method              = "GET"
      authorization            = "NONE"
      integration_type         = "HTTP_PROXY"
      integration_http_method  = "GET"
      integration_uri          = "https://api.catalogo.com/produtos"
      timeout_milliseconds     = 5000
    }
    
    # GET por ID - Buscar produto (Mock)
    GET_produto_id = {
      resource_id  = module.api_produtos.resource_ids["produto_id"]
      http_method  = "GET"
      authorization = "NONE"
      integration_type = "MOCK"
      
      integration_responses = {
        "200" = {
          response_templates = {
            "application/json" = jsonencode({
              "id" = "$input.params('id')",
              "nome" = "Produto $input.params('id')",
              "preco" = 99.99
            })
          }
        }
      }
    }
  }
}
```