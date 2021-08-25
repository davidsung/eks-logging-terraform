locals {
  account_id         = data.aws_caller_identity.current.account_id
  ecr_address        = format("%v.dkr.ecr.%v.amazonaws.com", local.account_id, data.aws_region.current.name)
  logstash_image_tag = coalesce(var.logstash_image_tag, formatdate("YYYYMMDDhhmmss", timestamp()))
  ecr_repo_url       = format("%v/%v", local.ecr_address, var.logstash_repo_name)
  ecr_image_name     = format("%v/%v:%v", local.ecr_address, var.logstash_repo_name, local.logstash_image_tag)
}
