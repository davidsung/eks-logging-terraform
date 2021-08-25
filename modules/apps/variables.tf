variable "region" {
  description = "AWS Region"
  type        = string
}

variable "cluster_id" {
  description = "EKS Cluster ID"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "EKS OIDC issuer url"
  type        = string
}

variable "kinesis_stream_name" {
  description = "Kinesis stream name"
  type        = string
}

variable "kinesis_stream_arn" {
  description = "Kinesis stream arn"
  type        = string
}

variable "es_endpoint" {
  description = "Elasticsearch endpoint"
  type        = string
}

variable "repository_name" {
  description = "ECR Repository Name"
  type        = string
  default     = "logging"
}

variable "fluent_bit_namespace" {
  description = "Fluentbit namespace"
  type        = string
  default     = "kube-system"
}

variable "fluent_bit_service_account_name" {
  description = "Fluentbit service account name in Kubernetes"
  type        = string
  default     = "aws-for-fluent-bit"
}

variable "fluent_bit_mem_buf_limit" {
  description = "Fluentbit default memory buffer limit"
  type        = string
  default     = "5MB"
}

variable "fluent_bit_output_kinesis_partition_key" {
  description = "Partition Key to determine which shards in Kinesis to produce, should be `null` if enabling KPL aggregation"
  type = string
  default = "kubernetes->pod_name"
}

variable "fluent_bit_output_kinesis_aggregation" {
  description = "Enable Kinesis aggregation in KPL"
  type = string
  default = "false"
}

variable "fluent_bit_log_level" {
  description = "Fluentbit Log Level"
  type        = string
  default     = "info"
}

variable "logstash_image_tag" {
  description = "Logstash Image Tag"
  type        = string
  default     = null
}

variable "logstash_repo_name" {
  description = "Logstash Repository Name"
  type        = string
  default     = "logstash"
}

variable "logstash_namespace" {
  description = "Kubernetes namespace name for logstash"
  type        = string
  default     = "logstash"
}

variable "create_logstash_namespace" {
  description = "Whether to logstash namespace"
  type        = bool
  default     = true
}

variable "logstash_service_account_name" {
  description = "Logstash service account name in Kubernetes"
  type        = string
  default     = "logstash-logstash"
}

variable "prometheus_namespace" {
  description = "Prometheus namespace"
  type        = string
  default     = "prometheus"
}

variable "create_prometheus_namespace" {
  description = "Whether to create namespace"
  type        = bool
  default     = true
}