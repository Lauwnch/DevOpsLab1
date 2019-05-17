output "security_id" {
  value = "${ aws_security_group.front.id }"
}

output "proxy_ip_private" {
  value = "${ aws_instance.proxy.*.private_ip }"
}

output "proxy_ip_public" {
  value = "${ aws_instance.proxy.*.public_ip }"
}

output "proxy_id" {
  value = "${ aws_instance.proxy.*.id }"
}

output "cache_id" {
  value = "${ aws_instance.cache.*.id }"
}

output "cache_ip_private" {
  value = "${ aws_instance.cache.*.private_ip }"
}
