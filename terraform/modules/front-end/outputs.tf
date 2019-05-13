output "security_id_front" {
  value = "${ aws_security_group.front.id }"
}

output "proxy_ip_private" {
  value = "${ aws_instance.proxy.private_ip }"
}

output "proxy_ip_public" {
  value = "${ aws_instance.proxy.public_ip }"
}

output "cache_ip_private" {
  value = "${ aws_instance.cache.private_ip }"
}
