output "nva_public_ip" {
  value = aws_instance.nva.public_ip
}
output "app_public_ip" {
  value = aws_instance.app.public_ip
}
