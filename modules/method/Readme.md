Módulo method
O que faz?
Este módulo configura os métodos HTTP (como GET, POST, OPTIONS) para um caminho da API. Ele define como a API responde às requisições, incluindo CORS (para permitir acesso de sites) e validações.
Como usar?

Informe o ID da API e do recurso (dos módulos api e resource).
Defina os métodos HTTP e como eles se conectam (ex.: a uma Lambda ou URL externa).
Configure CORS se precisar que a API seja acessada por um site.

Variáveis Principais

rest_api_id: ID da API (do módulo api).
resource_id: ID do recurso (do módulo resource).
methods: Mapa com os métodos HTTP (ex.: GET, POST) e suas configurações.
cors_allow_methods: Métodos permitidos para CORS (ex.: 'GET,POST,OPTIONS').
cors_allow_origin: Origens permitidas (ex.: '*' ou 'https://meusite.com').
cors_allow_headers: Headers permitidos (ex.: 'Authorization,Content-Type').
request_validators: Regras para validar as requisições (opcional).

Saídas (Outputs)

method_configs: Configurações dos métodos criados.

Exemplo
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

Dicas

Use integration_type = "AWS_PROXY" para conectar a uma Lambda.
Use integration_type = "MOCK" para métodos OPTIONS (necessário para CORS).
Adicione request_validators para verificar se as requisições estão corretas.
