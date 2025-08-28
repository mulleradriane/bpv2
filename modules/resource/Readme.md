🛣️ Módulo: Resource (modules/resource/)

Função
- Gerencia recursos/endpoints da API

## Uso Diário

```sh
module "resources" {
  source = "git::github.com/company/blueprints//modules/resource?ref=v2.0.0"
  
  api_id           = module.api.api_id
  root_resource_id = module.api.root_resource_id
  
  resources = {
    # Rotas simples
    users = { path_part = "users" }
    items = { path_part = "items" }
    
    # Rotas parametrizadas
    user_id = {
      path_part = "{id}"
      parent_id = "users"  # → /users/{id}
    }
    
    # Hierarquia complexa
    orders = { path_part = "orders" }
    order_items = {
      path_part = "items"
      parent_id = "orders"  # → /orders/items
    }
  }
}
```