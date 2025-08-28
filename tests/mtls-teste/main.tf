terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Teste com domínio fictício e truststore fictício
module "mutual_tls" {
  source = "../../modules/mutual_tls"

  domains = [
    {
      name              = "mtls-api.example.com"
      certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/fake-mtls-arn"
      security_policy   = "TLS_1_2"
      endpoint_type     = "REGIONAL"
      truststore_uri    = "s3://fake-bucket/truststore.pem"
      truststore_version = "v1"
      environment       = "test"
    }
  ]

  create_truststore_bucket = false  # Não criar bucket para teste
  create_client_policy     = false  # Não criar política para teste

  tags = {
    Environment = "test"
    TestType    = "mTLS"
  }
}

