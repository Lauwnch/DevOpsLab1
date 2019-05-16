output "security_id_bastion " {
  value = "${ aws_secuity_group.db.id }"
}

output "db_ip_private" {
  value = "${ aws_instance.database[*].private_ip }"
}

output "db_id" {
  value = "${ aws_instance.database[*].id }"
}
