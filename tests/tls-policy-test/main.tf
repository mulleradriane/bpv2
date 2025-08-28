module "tls_policy" {
  source = "../../modules/tls_policy"

  domains = [
    {
      name                     = "test-api-1.example.com"
      certificate_arn          = "arn:aws:acm:us-east-1:123456789012:certificate/fake-arn-1"
      endpoint_type            = "REGIONAL"
      security_policy          = "TLS_1_2"
      previous_security_policy = "TLS_1_0"
      tags                     = var.tags
    }
  ]

  create_enforcement_policy = var.create_enforcement_policy
  policy_name               = var.policy_name
}
