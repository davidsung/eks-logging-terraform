output "es_arn" {
  value = aws_elasticsearch_domain.this.arn
}

output "es_domain_name" {
  value = aws_elasticsearch_domain.this.domain_name
}

output "es_domain_endpoint" {
  value = aws_elasticsearch_domain.this.endpoint
}

output "es_security_group_id" {
  value = aws_security_group.es.id
}

output "es_kibana_endpoint" {
  value = aws_elasticsearch_domain.this.kibana_endpoint
}

output "nginx_security_group_id" {
  value = aws_security_group.nginx.id
}

output "nginx_public_dns" {
  value = var.nginx_enabled ? aws_instance.nginx.0.public_dns : null
}

output "nginx_public_ip" {
  value = var.nginx_enabled ? aws_instance.nginx.0.public_ip : null
}
