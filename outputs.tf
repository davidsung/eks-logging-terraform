# Output values
output "region" {
  value = var.aws_region
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_cluster_arn" {
  value = module.eks.cluster_arn
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

output "eks_logstash_namespace" {
  value = var.eks_logstash_namespace
}

output "kinesis_stream_arn" {
  value = module.stream.arn
}

output "kinesis_stream_name" {
  value = module.stream.name
}

output "logstash_repo_url" {
  value = module.apps.logstash_repository_url
}

output "logstash_repo_name" {
  value = module.apps.logstash_repository_name
}

output "logstash_image_tag" {
  value = module.apps.logstash_image_tag
}

output "logstash_iam_role_arn" {
  value = module.apps.logstash_iam_role_arn
}

output "es_domain_name" {
  value = module.elasticsearch.es_domain_name
}

output "es_domain_endpoint" {
  value = module.elasticsearch.es_domain_endpoint
}

output "es_kibana_endpoint" {
  value = module.elasticsearch.es_kibana_endpoint
}

output "es_nginx_public_dns" {
  value = module.elasticsearch.nginx_public_dns
}

output "es_nginx_public_ip" {
  value = module.elasticsearch.nginx_public_ip
}
