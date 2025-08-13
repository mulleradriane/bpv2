Módulo api
O que faz?
Este módulo cria uma API no AWS API Gateway (REST v1). É o ponto de partida para sua API, definindo o nome, descrição e um stage inicial (como dev ou prod).
Como usar?

Adicione o módulo ao seu main.tf.
Informe o nome da API e o nome do stage.
O módulo retorna o ID da API e o ID do recurso raiz, que você usará nos outros módulos.

Variáveis Principais

name: Nome da API (ex.: minha-api).
description: Uma breve descrição da API (opcional).
stage_name: Nome do stage inicial (ex.: dev, prod).

Saídas (Outputs)

id: ID da API criada.
root_resource_id: ID do recurso raiz (usado para criar outros caminhos).

Exemplo
module "api" {
  source      = "./modules/api"
  name        = "minha-api"
  description = "API para testes"
  stage_name  = "dev"
}

output "api_id" {
  value = module.api.id
}

Dicas

Use nomes descritivos para facilitar a identificação no AWS Console.
O stage inicial é apenas um ponto de partida; você pode criar mais stages no módulo deployment.
