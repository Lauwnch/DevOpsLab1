output "security_id" {
  value = "${ aws_security_group.app.id }"
}

output "app_ip_private" {
  value = "${ aws_instance.application.*.private_ip}"
}

output "app_id" {
  value = "${ aws_instance.application.*.id}"
}
