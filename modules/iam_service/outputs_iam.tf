output "role_arn" {
  description = "ARN da role IAM"
  value       = aws_iam_role.this.arn
}

variable "name" {
  description = "Nome da role IAM"
  type        = string
}

variable "assume_role_policy" {
  description = "JSON da assume role policy"
  type        = string
}

variable "policy_json" {
  description = "JSON da policy para a role"
  type        = string
}

variable "tags" {
  description = "Tags para a role"
  type        = map(string)
  default     = {}
}