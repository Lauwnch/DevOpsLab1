output "security_id" {
  value = "${ aws_security_group.bastion.id }"
}

output "bastion_ip_public" {
  value = "${ aws_instance.bastion.public_ip }"
}

output "bastion_ip_private" {
  value = "${ aws_instance.bastion.private_ip }"
}

output "bastion_id" {
  value = "${ aws_instance.bastion.id }"
}
