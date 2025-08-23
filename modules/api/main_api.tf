resource "null_resource" "validate_vpc_endpoint_ids" {
  count = var.endpoint_type == "PRIVATE" && length(var.vpc_endpoint_ids) == 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERRO: Quando endpoint_type é PRIVATE, vpc_endpoint_ids deve conter pelo menos um ID de endpoint VPC.' && exit 1"
  }
}


resource "aws_api_gateway_rest_api" "this" {
  name        = var.name
  description = var.description
  binary_media_types = var.binary_media_types
  minimum_compression_size = var.minimum_compression_size
  parameters = var.api_parameters
  body = var.openapi_body
  endpoint_configuration {
    types            = [var.endpoint_type]
    vpc_endpoint_ids = var.endpoint_type == "PRIVATE" ? var.vpc_endpoint_ids : null
  }
}