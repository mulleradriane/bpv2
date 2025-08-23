Considerações Adicionais

Tipo de Endpoint Personalizado: Se você precisar de um endpoint REGIONAL (em vez de EDGE), adicione o atributo regional_certificate_arn em vez de certificate_arn e especifique um ARN de certificado regional. Exemplo:

resource "aws_api_gateway_domain_name" "this" {
  domain_name              = var.domain_name
  regional_certificate_arn = var.certificate_arn  # Usar ARN regional
  security_policy          = "TLS_1_2"
  tags                     = var.tags
}

Ajuste var.certificate_arn para um ARN regional, se aplicável.