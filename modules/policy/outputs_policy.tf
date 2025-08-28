output "policy_json" {
  description = "Policy aplicada no API Gateway"
  value       = aws_api_gateway_rest_api_policy.this.policy
}
