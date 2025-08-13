Blueprint Terraform para API Gateway REST (v1)
O que é isso?
Esta é uma blueprint (um conjunto de códigos prontos) para criar APIs no AWS API Gateway usando Terraform. Ela é organizada em módulos para facilitar a criação de APIs, recursos, funções Lambda, métodos e implantações (deployments). É perfeita para quem está começando e para empresas que precisam gerenciar APIs grandes, até mesmo as que foram criadas manualmente no AWS Console.
Para quem é?

Pessoas iniciantes que querem aprender a criar APIs com Terraform.
Times que precisam importar APIs existentes para o Terraform.
Projetos que usam múltiplos ambientes (como dev, hml, prod) na mesma API.

Pré-requisitos

Terraform: Versão 1.0 ou superior.
AWS CLI: Configurada com uma conta AWS que tenha permissões para criar:
APIs no API Gateway.
Funções Lambda.
Funções IAM (roles e políticas).
Logs no CloudWatch.


Arquivo ZIP: Se usar Lambda, prepare um arquivo ZIP com o código da função.

Como usar?

Clone este repositório.
Entre no diretório do projeto e rode terraform init para baixar os módulos.
Edite o arquivo main.tf com as configurações da sua API.
Rode terraform plan para ver o que será criado.
Rode terraform apply para criar a API na AWS.

Módulos
Esta blueprint tem 5 módulos, cada um com uma função específica:

api: Cria a API principal no API Gateway.
resource: Adiciona caminhos (como /users ou /items/{id}) à API.
lambda: Cria funções Lambda para processar as requisições da API.
method: Configura os métodos HTTP (como GET, POST) e como eles funcionam.
deployment: Faz o deploy da API para torná-la acessível.

Cada módulo tem seu próprio README com instruções simples. Veja os arquivos em modules/[nome-do-módulo]/README.md.
Exemplo Simples
Aqui está um exemplo de como usar todos os módulos juntos em um main.tf:
provider "aws" {
  region = "us-east-1"
}

module "api" {
  source      = "./modules/api"
  name        = "minha-api"
  description = "Minha primeira API"
  stage_name  = "dev"
}

module "resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "teste"
}

module "lambda" {
  source        = "./modules/lambda"
  function_name = "minha-lambda"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda.zip"
}

module "method" {
  source        = "./modules/method"
  rest_api_id   = module.api.id
  resource_id   = module.resource.id
  authorization = "NONE"
  methods = {
    "GET" = {
      integration_type = "AWS_PROXY"
      uri              = module.lambda.uri
      enable_cors      = true
    }
    "OPTIONS" = {
      integration_type = "MOCK"
      enable_cors      = true
    }
  }
  cors_allow_methods = "'GET,OPTIONS'"
  cors_allow_origin  = "'*'"
  cors_allow_headers = "'Authorization,Content-Type'"
}

module "deployment" {
  source          = "./modules/deployment"
  rest_api_id     = module.api.id
  stage_name      = "dev"
  triggers_sha    = sha256(jsonencode(module.method.method_configs))
  deployment_description = "Primeiro deploy da API"
  stage_variables = {
    environment = "dev"
  }
}

output "invoke_url" {
  value = module.deployment.invoke_url
}

Como importar APIs existentes?
Se a API já existe na AWS (criada manualmente), você pode trazê-la para o Terraform:

Encontre o ID da API, recursos, e stages no AWS Console.
Use comandos como:terraform import module.api.aws_api_gateway_rest_api.this <api-id>
terraform import module.resource.aws_api_gateway_resource.this <api-id>/<resource-id>
terraform import module.deployment.aws_api_gateway_stage.this <api-id>/dev


Ajuste o main.tf para combinar com a API existente.
Rode terraform plan para verificar e terraform apply para sincronizar.

Dicas

Leia o README de cada módulo para entender o que ele faz.
Teste em um ambiente dev antes de usar em produção.
Use variáveis de stage (como environment=dev) para gerenciar diferentes ambientes.
Configure logs no CloudWatch para monitorar erros.
