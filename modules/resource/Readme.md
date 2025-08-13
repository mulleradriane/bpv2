Módulo resource
O que faz?
Este módulo cria caminhos (ou "recursos") na sua API, como /users ou /items/{id}. Cada caminho é um endereço que os usuários podem acessar na API.
Como usar?

Informe o ID da API (do módulo api).
Escolha o caminho pai (geralmente o root_resource_id da API).
Defina o nome do caminho (ex.: users ou {id} para um parâmetro).

Variáveis Principais

rest_api_id: ID da API (vem do módulo api).
parent_id: ID do recurso pai (ex.: root_resource_id para caminhos de nível 1).
path_part: Nome do caminho (ex.: users, {id} para parâmetros).

Saídas (Outputs)

id: ID do recurso criado (usado no módulo method).

Exemplo
module "resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "users"
}

output "resource_id" {
  value = module.resource.id
}

Dicas

Use {id} para criar caminhos dinâmicos (ex.: /items/{id}).
Você pode criar sub-caminhos chamando este módulo várias vezes (ex.: /items/{id}/details).
