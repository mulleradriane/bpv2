## 🚀 Como usar

### Exemplo mínimo:

```hcl
module "api" {
  source      = "./modules/api"
  name        = "minha-api"
  description = "API exemplo"
  stage_name  = "dev"
}

module "hello_lambda" {
  source        = "./modules/lambda"
  function_name = "hello"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  filename      = "${path.module}/hello.zip"
}

module "hello_resource" {
  source      = "./modules/resource"
  rest_api_id = module.api.id
  parent_id   = module.api.root_resource_id
  path_part   = "hello"
}

module "hello_methods" {
  source        = "./modules/method"
  rest_api_id   = module.api.id
  resource_id   = module.hello_resource.id
  lambda_uri    = module.hello_lambda.uri
  authorization = "NONE"
  methods       = ["GET", "POST"]
}

module "deployment" {
  source         = "./modules/deployment"
  rest_api_id    = module.api.id
  stage_name     = "dev"
  method_configs = module.hello_methods.method_configs
  triggers_sha   = sha1(jsonencode(module.hello_methods.method_configs))
  depends_on     = [module.hello_methods]
}
```

---

## ⚙️ Suporte ao método `ANY`

Caso deseje usar `methods = ["ANY"]`, o módulo `method` pode automaticamente expandir isso para todos os métodos padrão (GET, POST, etc), via a variável `expand_any`:

```hcl
module "teste_methods" {
  source        = "./modules/method"
  rest_api_id   = module.api.id
  resource_id   = module.teste_resource.id
  lambda_uri    = module.hello_lambda.uri
  authorization = "NONE"
  methods       = ["ANY"]
  expand_any    = true  # <-- Expande ANY para todos os métodos
}
```

Caso **não** queira expandir, e sim usar literalmente `ANY` como no console da AWS, basta deixar `expand_any = false` (padrão).

---

## 📌 Observações

- A expansão de `ANY` é útil para ambientes onde o método `ANY` não é suportado diretamente por algum recurso do Terraform.
- A variável `expand_any` é útil para evitar conflitos ou limitações na criação de métodos.
- O deploy só será atualizado se houver mudança nos métodos (`triggers_sha`).

O que significa o ANY no console da AWS
Quando você usa o console da AWS e escolhe ANY, ele está fazendo uma abstração visual que cria uma rota que responde a múltiplos métodos HTTP, desde que você tenha uma integração padrão (ex: Lambda Proxy).

- Na prática, ele registra um método para cada tipo: GET, POST, PUT, DELETE, etc., por trás do ANY. Ele só não mostra isso explicitamente no console para simplificar.
Ou seja, o ANY não é um método HTTP real. O que acontece é:

- O console interpreta ANY como “todos os métodos HTTP comuns”
- O Terraform e a AWS CLI precisam de nomes explícitos de métodos (GET, POST, etc.)
- A API Gateway internamente trata cada método separado


Você pode usar ANY no console AWS para criar rapidamente métodos com o mesmo comportamento, mas no Terraform, para manter controle total e não depender de "atalhos visuais", o correto é definir todos os métodos explicitamente:

```hcl
methods = ["GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"]
```

Isso garante que:
- Você pode configurar method_response e integration_response
- Evita erros 404 / ConflictException
- Seu código é 100% portável entre ambientes e não depende de comportamento específico do console

