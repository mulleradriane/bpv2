resource "aws_s3_bucket" "truststore" {
  count = var.create_truststore_bucket ? 1 : 0

  bucket = var.truststore_bucket_name
}

# Configurações do bucket separadas
resource "aws_s3_bucket_ownership_controls" "truststore" {
  count = var.create_truststore_bucket ? 1 : 0

  bucket = aws_s3_bucket.truststore[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "truststore" {
  count = var.create_truststore_bucket ? 1 : 0

  bucket = aws_s3_bucket.truststore[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "truststore" {
  count = var.create_truststore_bucket ? 1 : 0

  bucket = aws_s3_bucket.truststore[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Upload do arquivo truststore
resource "aws_s3_object" "truststore" {
  count = var.truststore_file_path != null ? 1 : 0

  bucket = var.create_truststore_bucket ? aws_s3_bucket.truststore[0].id : var.existing_truststore_bucket
  key    = var.truststore_file_name
  source = var.truststore_file_path
  etag   = filemd5(var.truststore_file_path)

  tags = merge(var.tags, {
    Purpose = "mTLS-truststore-file"
  })
}

# Domain Name com mTLS habilitado
resource "aws_api_gateway_domain_name" "mtls" {
  for_each = { for domain in var.domains : domain.name => domain }

  domain_name              = each.value.name
  regional_certificate_arn = each.value.certificate_arn
  security_policy          = each.value.security_policy

  mutual_tls_authentication {
    truststore_uri     = each.value.truststore_uri
    truststore_version = each.value.truststore_version
  }

  endpoint_configuration {
    types = [each.value.endpoint_type]
  }

  tags = merge(each.value.tags, {
    ManagedBy   = "Terraform"
    MutualTLS   = "enabled"
    Environment = each.value.environment
  })

  lifecycle {
    ignore_changes = [
      regional_certificate_arn,
      mutual_tls_authentication[0].truststore_version
    ]
  }
}

# Policy IAM para clientes mTLS
data "aws_iam_policy_document" "mtls_client" {
  count = var.create_client_policy ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["apigateway:Invoke"]
    resources = [for domain in aws_api_gateway_domain_name.mtls : domain.arn]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "mtls_client" {
  count = var.create_client_policy ? 1 : 0

  name        = var.client_policy_name
  description = "Policy for mTLS clients to access API Gateway"
  policy      = data.aws_iam_policy_document.mtls_client[0].json

  tags = merge(var.tags, {
    Purpose = "mTLS-client-policy"
  })
}