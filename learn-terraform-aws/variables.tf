variable "instance_name" {
  description = "EC2 インスタンスの Name タグ"
  type        = string
  default     = "learn-terraform"
}

variable "instance_type" {
  description = "EC2 インスタンスタイプ"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = startswith(var.instance_type, "t3.")
    error_message = "ハンズオンでは t3 系のインスタンスタイプだけを使います。"
  }
}
