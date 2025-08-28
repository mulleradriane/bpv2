data "aws_acm_certificate" "default" {
  domain   = "*.${var.environment}.company.com"  # Padrão corporativo
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "environment" {
  name         = "${var.environment}.company.com."
  private_zone = false
}

data "aws_api_gateway_domain_name" "existing" {
  count = var.use_existing_domain ? 1 : 0
  
  domain_name = "api.${var.environment}.company.com"
}


