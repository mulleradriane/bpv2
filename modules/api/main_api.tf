resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = var.description

  api_key_source           = var.api_key_source
  minimum_compression_size = var.minimum_compression_size

  # verificar se não é null antes de usar length()
  binary_media_types = (
    var.binary_media_types != null ? (
      length(var.binary_media_types) > 0 ? sort(var.binary_media_types) : null
    ) : null
  )

  endpoint_configuration {
    types            = [var.endpoint_type]
    vpc_endpoint_ids = var.vpc_endpoint_ids
  }

  tags = merge(
    {
      Product     = var.product
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

module "corporate_policy" {
  source = "../corporate_policy"

  rest_api_id = aws_api_gateway_rest_api.this.id
  region      = var.region
  custom_policy = var.custom_policy  # Opcional: políticas adicionais
}


# Account-level settings - suporta múltiplas regiões
resource "aws_api_gateway_account" "this" {
  count = var.manage_account_level_settings ? 1 : 0

  cloudwatch_role_arn = var.cloudwatch_role_arn

  # Garante que só executa após a role estar criada
  depends_on = [var.cloudwatch_role_dependency]
}
