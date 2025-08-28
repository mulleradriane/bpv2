# Criação de recursos do API Gateway
resource "aws_api_gateway_resource" "this" {
  for_each = var.resources

  rest_api_id = var.api_id
  parent_id   = each.value.parent_id != null ? each.value.parent_id : var.root_resource_id
  path_part   = each.value.path_part
}
