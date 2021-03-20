
output "nva_public_ip" {
  description = "NVA Public IP"
  value       = aws_instance.nva.public_ip
}

output "app_public_ip" {
  description = "App host Public IP"
  value       = aws_instance.app.public_ip
}

output "app_private_ip" {
  description = "App host Private IP"
  value       = aws_instance.app.private_ip
}
