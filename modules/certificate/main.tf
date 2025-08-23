resource "aws_api_gateway_domain_name" "this" {
  domain_name              = var.domain_name
  certificate_arn          = var.certificate_arn
  security_policy          = "TLS_1_2"
  tags                     = var.tags
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = var.rest_api_id
  stage_name  = var.stage_name
  domain_name = aws_api_gateway_domain_name.this.domain_name
  base_path   = var.base_path  # Caminho base opcional (padrão vazio)
}
