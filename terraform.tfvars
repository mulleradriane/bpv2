environment         = "dev"
product             = "my-api"
default_allowed_ips = ["192.0.2.0/24", "198.51.100.0/24"]
default_certificates = {
  dev = "arn:aws:acm:us-east-1:123456789012:certificate/abc123-xyz789"
  hml = "arn:aws:acm:us-east-1:123456789012:certificate/def456-uvw012"
  prd = "arn:aws:acm:us-east-1:123456789012:certificate/ghi789-jkl345"
}
default_domain = {
  dev = "api.dev.example.com"
  hml = "api.hml.example.com"
  prd = "api.prd.example.com"
}
base_path = "v1"
tags = {
  environment = "dev"
  product     = "my-api"
  team        = "devops"
}
endpoint_type = "REGIONAL"
vpc_endpoint_ids = []