output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "uri" {
  description = "URI do Lambda para integração com API Gateway"
  value       = aws_lambda_function.this.invoke_arn
}
