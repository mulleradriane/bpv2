Blueprint para AWS API Gateway (BPv2)
  
Bem-vindo à blueprint (BPv2) para criar e gerenciar um API Gateway na AWS usando Terraform! Esta documentação é feita para ajudar iniciantes e pessoas com pouco contato com API Gateway (APIGW) e Terraform a entender o projeto e subir uma API funcional. Vamos criar uma API simples com endpoints, políticas de segurança (ex.: IPs permitidos), e integração com uma função Lambda, tudo de forma automatizada.
O que é esta Blueprint?
Esta é uma estrutura de código Terraform que automatiza a criação de um API Gateway na AWS. Ela inclui:

Uma API pública com endpoints como /hello e /items/{id}.
Uma função Lambda para processar requisições.
Políticas de segurança para controlar quem pode acessar a API (baseado em IPs).
Uma role IAM para pipelines de CI/CD (ex.: GitLab).
Configurações básicas para deploy e monitoramento.

O objetivo é facilitar a criação de APIs escaláveis e seguras, com suporte a ajustes futuros (ex.: múltiplos ambientes como dev, hml, prd).
Pré-requisitos
Antes de começar, certifique-se de ter o seguinte configurado:

AWS CLI Instalada e Configurada:

Instale a AWS CLI (https://aws.amazon.com/cli/) e configure suas credenciais com aws configure.
Exemplo: Insira sua AWS Access Key ID, Secret Access Key, região (ex.: us-east-1), e formato de saída (ex.: json).


Terraform Instalado:

Baixe e instale o Terraform (https://www.terraform.io/downloads.html). Versão recomendada: 1.5.x ou superior.
Verifique a instalação com terraform -v.


Permissões na AWS:

A conta AWS usada deve ter permissões para criar:
API Gateways (apigateway:*).
Funções Lambda (lambda:*).
Roles IAM (iam:*).
Logs CloudWatch (logs:*).


Se usar GitLab CI/CD, configure um provedor OIDC (explicado mais adiante).


Ambiente Local:

Clone este repositório ou copie os arquivos para um diretório chamado BPV2/.



Estrutura do Projeto
Aqui está como os arquivos estão organizados dentro da pasta BPV2/:

main.tf: O arquivo principal que define a API, políticas, e integrações.
outputs.tf: Mostra os resultados (ex.: URL da API) após a criação.
variables.tf: Configurações que você pode ajustar (ex.: IPs permitidos, nome da API).
modules/: Contém os blocos de construção reutilizáveis (ex.: API, deploy, IAM).
hello.zip: Um arquivo com o código da função Lambda (inclui index.js).
index.js: Código simples da Lambda que responde às requisições.
README.md: Esta documentação!

Como Subir um API Gateway
Siga estes passos para criar sua API na AWS:
1. Configure as Variáveis
Abra o arquivo variables.tf e veja as opções que você pode ajustar. Para começar, crie um arquivo terraform.tfvars na pasta BPV2/ com valores básicos. Exemplo:
environment = "dev"          # Ambiente (ex.: dev, hml, prd)
product     = "my-api"       # Nome do produto ou API
default_allowed_ips = ["192.0.2.0/24", "198.51.100.0/24"]  # IPs permitidos (ajuste para sua rede)


environment: Define o ambiente da API (usado no nome do stage).
product: Nome da sua API (usado no nome do recurso).
default_allowed_ips: Lista de endereços IP que podem acessar a API (substitua pelos IPs da sua empresa).

2. Inicialize o Terraform
No terminal, navegue até a pasta BPV2/ e rode:
terraform init

Isso baixa os provedores necessários (ex.: AWS) e prepara o ambiente.
3. Veja o Plano de Execução
Rode:
terraform plan -var-file="terraform.tfvars"


O Terraform mostrará o que será criado (API, Lambda, roles, etc.).
Revise os outputs para confirmar a URL da API e outros detalhes.

4. Aplique as Mudanças
Se tudo parecer correto, aplique o plano:
terraform apply -var-file="terraform.tfvars"


Digite yes quando solicitado.
Aguarde alguns minutos. O Terraform criará a API e mostrará os resultados.

5. Teste a API
Após o apply, anote a URL da API no output (ex.: https://abc123.execute-api.us-east-1.amazonaws.com/dev/hello).

Use uma ferramenta como Postman ou cURL para testar:curl https://abc123.execute-api.us-east-1.amazonaws.com/dev/hello


Você deve ver uma resposta da Lambda (ex.: { "message": "Hello from Lambda!" }).

6. Limpe os Recursos (Opcional)
Quando terminar, remova tudo da AWS com:
terraform destroy -var-file="terraform.tfvars"


Digite yes para confirmar.

Funcionalidades Atuais
Endpoints

/hello: Retorna uma mensagem simples via Lambda.
/items/{id}: Permite consultar um item por ID (retorna 404 se não encontrado).

Segurança

Política de IPs: Só permite acesso de IPs listados em default_allowed_ips.
Regras de Deny: Você pode adicionar regras para bloquear IPs específicos (veja deny_rules em variables.tf).
IAM para CI/CD: Inclui uma role para pipelines (ex.: GitLab) gerenciar a API.

Integração

A API usa uma função Lambda (hello.zip) para processar requisições.

Uso dos Módulos no main.tf
O arquivo main.tf é o "coração" do projeto, onde todos os módulos são chamados e conectados. Cada módulo é responsável por uma parte específica da API Gateway. Aqui está uma explicação simples de como cada módulo é usado no main.tf, com exemplos de código e o que ele faz:
Módulo api (Cria a API Gateway Principal)

O que faz: Cria o recurso principal da API Gateway, definindo nome, descrição e configurações básicas.
Como é chamado no main.tf:module "api" {
  source      = "./modules/api"
  name        = local.name
  description = format("Public API for %s", local.product)
  stage_name  = var.environment
  tags        = var.tags
}


Dicas para uso: Ajuste name e description via variáveis em terraform.tfvars. Isso é o primeiro módulo a ser criado.

Módulo api_policy (Configura Políticas de Segurança)

O que faz: Aplica uma policy à API para controlar acesso (ex.: por IPs).
Como é chamado no main.tf:module "api_policy" {
  source      = "./modules/policy"
  rest_api_id = module.api.id
  policy      = var.custom_api_policy != null ? var.custom_api_policy : local.api_policy
  depends_on  = [module.api]
}


Dicas para uso: A policy é gerada automaticamente em local.api_policy. Para customizar, defina custom_api_policy no terraform.tfvars.

Módulo iam_service (Cria Role IAM para CI/CD)

O que faz: Cria uma role IAM para ferramentas como GitLab gerenciarem a API.
Como é chamado no main.tf:module "iam_service" {
  source = "./modules/iam_service"
  name        = "${local.name}-ci-role"
  assume_role_policy = jsonencode({...})  # Configuração para OIDC
  policy_json = local.ci_policy
  tags        = var.tags
}


Dicas para uso: Ajuste o assume_role_policy para o seu provedor OIDC. Isso é útil para automação.

Módulo lambda_hello (Cria Função Lambda)

O que faz: Cria uma função Lambda para processar requisições.
Como é chamado no main.tf:module "lambda_hello" {
  source        = "./modules/lambda"
  function_name = format("%s-hello-lambdav2", local.product)
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "${path.module}/hello.zip"
  tags          = var.tags
}


Dicas para uso: O código da Lambda está em hello.zip. Para mudar a função, atualize index.js e rezip o arquivo.

Módulos hello_resource e item_resource (Cria Recursos/Endpoints)

O que faz: Define caminhos na API (ex.: /hello e /items/{id}).
Como é chamado no main.tf (exemplo para /hello):module "hello_resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "hello"
}


Dicas para uso: Use para adicionar novos endpoints. O path_part define a URL.

Módulos hello_methods e item_methods (Cria Métodos HTTP)

O que faz: Define ações HTTP (ex.: GET, POST) nos endpoints.
Como é chamado no main.tf (exemplo para /hello):module "hello_methods" {
  source        = "./modules/method"
  rest_api_id   = module.api.id
  resource_id   = module.hello_resource.id
  authorization = "NONE"
  methods       = { ... }  # Definições de GET, POST, etc.
}


Dicas para uso: Ajuste methods para adicionar suporte a CORS ou integrações (ex.: com Lambda).

Módulo deployment (Faz o Deploy da API)

O que faz: Publica a API e cria um stage (ex.: dev).
Como é chamado no main.tf:module "deployment" {
  source                 = "./modules/deployment"
  rest_api_id            = module.api.id
  stage_name             = var.environment
  triggers_sha           = local.methods_hash
  deployment_description = "Atualização automática da API"
  stage_variables        = { environment = var.environment, version = "v2" }
  tags                   = var.tags
  depends_on             = [module.hello_methods, module.item_methods]
}


Dicas para uso: O triggers_sha garante deploys automáticos quando métodos mudam.

Para ver todos os módulos em ação, abra main.tf — ele conecta tudo! Se quiser adicionar um novo módulo, siga o padrão: defina no modules/ e chame na raiz.
Configurações Avançadas
Adicionar Regras de Bloqueio (Deny)
Se quiser bloquear certos IPs, edite o terraform.tfvars com:
deny_rules = {
  "DenyNonCorp" = {
    Condition = {
      "NotIpAddress" = {
        "aws:SourceIp" = ["10.0.0.0/8"]
      }
    }
  }
}

Rode terraform plan e apply novamente.
Usar com GitLab CI/CD

Configure um provedor OIDC no AWS IAM para o GitLab.
Ajuste o assume_role_policy no main.tf com o ARN correto do seu OIDC provider (ex.: arn:aws:iam::123456789012:oidc-provider/gitlab.com).
Crie um pipeline no GitLab para rodar terraform apply.

Dicas para Iniciantes

Erros Comuns: Se vir "permission denied", verifique suas credenciais AWS. Se o plano falhar, cheque os IPs em default_allowed_ips.
Documentação AWS: Veja docs.aws.amazon.com/apigateway para mais detalhes sobre API Gateway.
Ajuda: Se algo der errado, consulte este README ou peça apoio ao time de DevOps.

Próximos Passos
Esta blueprint ainda está em desenvolvimento. Em breve, vamos adicionar:

Suporte a múltiplos ambientes (dev, hml, prd).
Certificados SSL e domínios personalizados.
Logging e monitoramento (ex.: X-Ray).

Fique atento para atualizações!