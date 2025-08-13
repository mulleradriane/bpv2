Módulo deployment
O que faz?
Este módulo faz o deploy da API para que ela fique disponível na AWS. Ele cria um stage (como dev ou prod) e configura opções como variáveis de stage, throttling e logs.
Como usar?

Informe o ID da API e o nome do stage.
Passe o triggers_sha (gerado no main.tf) para atualizar o deploy quando a API mudar.
Opcionalmente, adicione uma descrição para o deploy e variáveis de stage.

Variáveis Principais

rest_api_id: ID da API (do módulo api).
stage_name: Nome do stage (ex.: dev, prod).
triggers_sha: Hash que força um novo deploy quando a API muda.
deployment_description: Descrição do deploy (ex.: "Primeiro deploy").
stage_variables: Variáveis para o stage (ex.: { environment = "dev" }).
throttle_settings: Limites de requisições (opcional).
tags: Tags para identificar os recursos (opcional).

Saídas (Outputs)

deployment_id: ID do deploy.
invoke_url: URL para acessar a API.
stage_arn: ARN do stage.

Exemplo
module "deployment" {
  source          = "./modules/deployment"
  rest_api_id     = module.api.id
  stage_name      = "dev"
  triggers_sha    = sha256(jsonencode(module.method.method_configs))
  deployment_description = "Primeiro deploy da API"
  stage_variables = {
    environment = "dev"
  }
  tags = {
    Environment = "dev"
  }
}

output "invoke_url" {
  value = module.deployment.invoke_url
}

Dicas

Use stage_variables para configurar diferentes ambientes (ex.: dev, prod).
O triggers_sha garante que a API é atualizada automaticamente quando você muda métodos.
Adicione logging_level = "INFO" para monitorar requisições no CloudWatch.
