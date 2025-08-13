Módulo lambda
O que faz?
Este módulo cria uma função Lambda na AWS, que pode ser usada para processar requisições da sua API. Ele também cria as permissões necessárias para a API Gateway chamar a Lambda.
Como usar?

Informe o nome da função, o runtime (ex.: nodejs18.x), o handler, e o arquivo ZIP com o código.
O módulo retorna o URI e ARN da Lambda, que você usará no módulo method.

Variáveis Principais

function_name: Nome da função Lambda (ex.: minha-lambda).
runtime: Linguagem da Lambda (ex.: nodejs18.x, python3.9).
handler: Nome do handler (ex.: index.handler).
filename: Caminho para o arquivo ZIP com o código da Lambda.

Saídas (Outputs)

uri: URI da Lambda para integração com API Gateway.
arn: ARN da função Lambda.

Exemplo
module "lambda" {
  source        = "./modules/lambda"
  function_name = "minha-lambda"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "lambda.zip"
}

output "lambda_uri" {
  value = module.lambda.uri
}

Dicas

Crie o arquivo ZIP com o código da Lambda antes de rodar o Terraform.
Use nomes únicos para function_name para evitar conflitos.
