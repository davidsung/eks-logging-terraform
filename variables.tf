variable "environment" {
  description = "Environment"
  default     = "staging"
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "key_alias" {
  default = "logging"
}

// VPC
variable "vpc_name" {
  description = "VPC Name"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
}

// EKS
variable "eks_cluster_prefix" {
  type        = string
  default     = "cluster"
  description = "EKS Cluster Prefix"
}

variable "eks_cluster_version" {
  type        = string
  default     = "1.21"
  description = "EKS Version"
}

variable "eks_node_group_desired_capacity" {
  type        = number
  default     = 3
  description = "EKS node group desired capacity"
}

variable "eks_node_group_min_capacity" {
  type        = number
  default     = 3
  description = "EKS node group minimum capacity"
}

variable "eks_node_group_max_capacity" {
  type        = number
  default     = 6
  description = "EKS node group maximum capacity"
}

variable "eks_node_group_instance_types" {
  type        = list(string)
  default     = ["m5.large"]
  description = "EKS node group instance type"
}

variable "eks_node_group_capacity_type" {
  type        = string
  default     = "ON_DEMAND"
  description = "EKS node group capacity type"
}

variable "eks_enable_irsa" {
  type        = bool
  default     = true
  description = "Enable IRSA"
}

variable "eks_map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "eks_write_kubeconfig" {
  description = "Whether to write kubeconfig file"
  type        = bool
  default     = false
}

variable "eks_fluent_bit_mem_buf_limit" {
  type        = string
  default     = "5MB"
  description = "EKS Fluentbit default memory buffer limit"
}

variable "eks_fluent_bit_log_level" {
  type        = string
  default     = "info"
  description = "EKS Fluentbit Log Level"
}

variable "eks_logstash_namespace" {
  type        = string
  default     = "logstash"
  description = "Kubernetes namespace name for logstash"
}

variable "logstash_image_tag" {
  type        = string
  default     = "0.1.0"
  description = "Customized logstash image tag"
}

// Kinesis Data Stream
variable "kinesis_stream_name" {
  type        = string
  default     = "data_stream"
  description = "Kinesis Data Stream Name"
}

variable "kinesis_stream_shard_count" {
  type        = number
  default     = 1
  description = "Number of shards in Kinesis Data Stream"
}

variable "kinesis_stream_retention_period" {
  type        = number
  default     = 24 # One day
  description = "Retention Period for Kinesis Data Stream"
}

variable "kinesis_stream_encryption_type" {
  type        = string
  default     = "NONE"
  description = "Kinesis stream encryption type"
}

variable "kinesis_stream_shard_level_metrics" {
  type = list(string)
  default = [
    "IncomingBytes",
    "IncomingRecords",
    "WriteProvisionedThroughputExceeded",
  ]
  description = "Enable Kinesis Enhanced Monitoring on shard level"
}

variable "kinesis_stream_autoscaling_enabled" {
  type        = bool
  default     = true
  description = "Enable Kinesis Stream autoscaling by lambda and cloudwatch alarm"
}

// Kinesis Data Firehose
variable "firehose_stream_name" {
  type        = string
  default     = "delivery_stream"
  description = "Kinesis Data Firehose Stream Name"
}

// Amazon Elasticsearch
variable "es_domain" {
  type        = string
  description = "Amazon Elasticsearch Domain Name"
}

variable "es_version" {
  type        = string
  default     = "7.10"
  description = "Amazon Elasticsearch Version"
}

variable "es_instance_type" {
  type    = string
  default = "t2.small.elasticsearch"
}

variable "es_instance_count" {
  type    = number
  default = 1
}

variable "es_warm_enabled" {
  type        = bool
  default     = false
  description = "Enable Elasticsearch Ultrawarm instance"
}

variable "es_warm_type" {
  type        = string
  default     = "ultrawarm1.medium.elasticsearch"
  description = "Elasticsearch Ultrawarm instance type"
}

variable "es_warm_count" {
  type        = number
  default     = 2
  description = "Elasticsearch Ultrawarm instance count"

  validation {
    condition     = var.es_warm_count >= 2 || var.es_warm_count <= 150
    error_message = "The number of Ultrawarm instances must be between 2 and 150."
  }
}

variable "es_dedicated_master_enabled" {
  type    = bool
  default = false
}

variable "es_dedicated_master_type" {
  type    = string
  default = "t2.small.elasticsearch"
}

variable "es_dedicated_master_count" {
  type    = number
  default = 1
}

variable "es_automated_snapshot_start_hour" {
  type    = number
  default = 0
}

// Cognito
variable "es_cognito_enabled" {
  type    = bool
  default = false
}

variable "es_cognito_identity_pool_id" {
  type    = string
  default = null
}

variable "es_cognito_user_pool_id" {
  type    = string
  default = null
}

variable "es_cognito_role_arn" {
  type    = string
  default = null
}

// ebs_options
variable "es_volume_type" {
  type    = string
  default = "gp2"
}

variable "es_volume_size" {
  type    = string
  default = 10
}

variable "es_zone_awareness_enabled" {
  type    = bool
  default = false
}

variable "es_availability_zone_count" {
  type    = number
  default = 1
}

variable "es_encrypt_at_rest_enabled" {
  type    = bool
  default = true
}

variable "es_create_iam_service_linked_role" {
  type    = bool
  default = true
}

variable "kibana_whitelist_cidr" {
  description = "Whitelist CIDR for accessing Kibana"
  type        = string
}