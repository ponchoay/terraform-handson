output "instance_id" {
  description = "EC2 インスタンスの ID"
  value       = aws_instance.web.id
}

output "instance_public_ip" {
  description = "EC2 インスタンスのパブリック IP"
  value       = aws_instance.web.public_ip
}

output "instance_hostname" {
  description = "EC2 インスタンスのプライベート DNS 名"
  value       = aws_instance.web.private_dns
}
