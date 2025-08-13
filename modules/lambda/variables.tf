variable "function_name" {
  type = string
}

variable "runtime" {
  type = string
  default = "nodejs18.x"
}

variable "handler" {
  type = string
}

variable "filename" {
  type = string
  description = "Arquivo .zip da função Lambda"
}
