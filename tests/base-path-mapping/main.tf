module "base_path_mapping" {
  source = "../../modules/base_path_mapping"

  mappings = [
    {
      key         = "real-mapping"
      api_id      = "sua-api-id-real"
      stage_name  = "prod"
      domain_name = "seu-dominio-real.com"  # ✅ Domain real
      base_path   = "api"
    }
  ]
}