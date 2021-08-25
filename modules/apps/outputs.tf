output "fluent_kit_iam_role_arn" {
  value = module.fluent_bit_irsa.iam_role_arn
}

output "logstash_iam_role_arn" {
  value = module.logstash_irsa.iam_role_arn
}

output "logstash_repository_url" {
  value = local.ecr_repo_url
}

output "logstash_repository_name" {
  value = aws_ecr_repository.this.id
}

output "logstash_image_tag" {
  value = local.logstash_image_tag
}