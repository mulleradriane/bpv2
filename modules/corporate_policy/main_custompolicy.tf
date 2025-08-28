# modules/corporate_policy/main_custompolicy.tf
data "aws_caller_identity" "current" {}

locals {
  # Template dos IPs corporativos
  corporate_statement = {
    Effect    = "Allow"
    Principal = "*"
    Action    = "execute-api:Invoke"
    Resource  = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${var.rest_api_id}/*/*/*"
    Condition = {
      IpAddress = {
        "aws:SourceIp" = var.mandatory_ips
      }
    }
  }

  # Statements customizados (se fornecidos)
  custom_statements = var.custom_policy != null ? (
    can(var.custom_policy.Statement) ? var.custom_policy.Statement : []
  ) : []

  # Política final validada
  final_policy_validated = {
    Version   = "2012-10-17"
    Statement = concat([local.corporate_statement], local.custom_statements)
  }
}

resource "aws_api_gateway_rest_api_policy" "corporate" {
  rest_api_id = var.rest_api_id
  policy      = jsonencode(local.final_policy_validated)
}

# Validações de segurança
resource "null_resource" "policy_validation" {
  lifecycle {
    precondition {
      condition     = length(var.mandatory_ips) > 0
      error_message = "Lista de IPs obrigatórios não pode estar vazia."
    }
    
    precondition {
      condition     = alltrue([for ip in var.mandatory_ips : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$|^[0-9a-fA-F:]+/[0-9]{1,3}$", ip))])
      error_message = "Todos os IPs obrigatórios devem estar no formato CIDR válido."
    }
    
    precondition {
      condition     = var.custom_policy == null ? true : can(var.custom_policy.Version) && can(var.custom_policy.Statement)
      error_message = "Custom policy must include Version and Statement fields if provided."
    }
  }
}

