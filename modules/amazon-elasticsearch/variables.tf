variable "domain_name" {
  type = string
}
variable "elasticsearch_version" {
  type = string
  default = "7.9"
}

variable "create_iam_service_linked_role" {
  type = bool
  default = true
}

variable "vpc_enabled" {
  type = bool
  default = true
}

variable "vpc_id" {
  type = string
  default = ""
}

variable "inbound_cidr_blocks" {
  type = list(string)
  default = []
}

variable "ebs_volume_type" {
  type = string
  default = "gp2"
  description = "(Optional) The type of EBS volumes attached to data nodes"
}

variable "ebs_volume_size" {
  type = number
  default = 10
  description = "The size of EBS volumes attached to data nodes (in GiB)"
}
variable "ebs_iops" {
  type = number
  default = 0
  description = "(Optional) The baseline input/output (I/O) performance of EBS volumes attached to data nodes. Applicable only for the Provisioned IOPS EBS volume type"
}

variable "instance_type" {
  type = string
  default = "t2.small.elasticsearch"
}

variable "instance_count" {
  type = number
  default = 1
}

variable "dedicated_master_enabled" {
  type = bool
  default = false
  description = "(Optional) Indicates whether dedicated master nodes are enabled for the cluster"
}

variable "dedicated_master_type" {
  type = string
  default = "t2.small.elasticsearch"
  description = "(Optional) Instance type of the dedicated master nodes in the cluster"
}

variable "dedicated_master_count" {
  type = number
  default = 0
  description = "(Optional) Number of dedicated master nodes in the cluster. Never choose an even number of dedicated master nodes. Generally 3 dedicated master nodes is a good choice for production"
}

variable "warm_enabled" {
  type = bool
  default = false
}
variable "warm_count" {
  type = number
  default = 2
  validation {
    condition = (var.warm_count >= 2 && var.warm_count <= 150)
    error_message = "The number of warm nodes should be in the range of 2 - 150."
  }
}
variable "warm_type" {
  type = string
  default = "ultrawarm1.medium.elasticsearch"
}
variable "zone_awareness_enabled" {
  type = bool
  default = false
}
variable "availability_zone_count" {
  type = number
  default = 2
}
variable "advanced_options" {
  type = map(string)
  default = {
    "override_main_response_version": "false"
    "rest.action.multi.allow_explicit_index": "true"
  }
}
//advanced_security_options
variable "advanced_security_options_enabled" {
  type = bool
  default = false
  description = "(Required, Forces new resource) Whether advanced security is enabled"
}
variable "advanced_security_options_internal_user_database_enabled" {
  type = bool
  default = false
}
variable "advanced_security_options_master_user_arn" {
  type = string
  default = ""
}
variable "advanced_security_options_master_user_name" {
  type = string
  default = ""
}
variable "advanced_security_options_master_user_password" {
  type = string
  default = ""
}
//cognito_options
variable "cognito_auth_enabled" {
  type = bool
  default = false
}

variable "cognito_endpoint" {
  type = string
  default = ""
}

variable "cognito_identity_pool_id" {
  type = string
  default = ""
}

variable "cognito_role_arn" {
  type = string
  default = ""
}

variable "cognito_user_pool_id" {
  type = string
  default = ""
}

//encrypt_at_rest
variable "encrypt_at_rest_enabled" {
  type = bool
  default = false
}
variable "encrypt_at_rest_kms_key_id" {
  type = string
  default = ""
}
//node_to_node_encryption
variable "node_to_node_encryption_enabled" {
  type = bool
  default = false
}
//snapshot_options
variable "automated_snapshot_start_hour" {
  type = number
  default = 0
}
//vpc_options
variable "inbound_security_group_id" {
  type = string
  default = null
}

variable "vpc_subnet_ids" {
  type = list(string)
  default = []
  description = "For instance count = 1, vpc_subnet_ids must contain 1 subnet id"
}

//log_publishing_options
variable "log_publishing_index_slow_enabled" {
  type = bool
  default = false
}

variable "log_publishing_index_slow_cloudwatch_log_group_arn" {
  type = string
  default = ""
}

variable "log_publishing_search_slow_enabled" {
  type = bool
  default = false
}

variable "log_publishing_search_slow_cloudwatch_log_group_arn" {
  type = string
  default = ""
}

variable "log_publishing_es_application_enabled" {
  type = bool
  default = false
}

variable "log_publishing_es_application_cloudwatch_log_group_arn" {
  type = string
  default = ""
}

variable "log_publishing_audit_enabled" {
  type = bool
  default = false
}

variable "log_publishing_audit_cloudwatch_log_group_arn" {
  type = string
  default = ""
}

//domain_endpoint_options
variable "domain_endpoint_options_enforce_https" {
  type = bool
  default = false
}
variable "domain_endpoint_options_tls_security_policy" {
  type = string
  default = "Policy-Min-TLS-1-0-2019-07"
}

// nginx
variable "nginx_enabled" {
  type = bool
  default = false
}

variable "nginx_instance_name" {
  type = string
  default = "nginx-kibana"
}

variable "nginx_instance_type" {
  type = string
  default = "t3.medium"
}

variable "nginx_subnet_id" {
  type = string
  default = null
}

variable "nginx_cidr_block" {
  type = string
  default = null
}

variable "nginx_ssh_key_name" {
  type = string
  default = ""
}

variable "tags" {
  type = map(string)
  default = {}
}