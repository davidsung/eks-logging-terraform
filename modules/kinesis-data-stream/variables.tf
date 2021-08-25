variable "name" {}

variable "shard_count" {
  type = number
}

variable "retention_period" {
  type    = number
  default = 24
}

variable "encryption_type" {
  type        = string
  default     = "NONE"
  description = "The encryption type to use. Possible values are 'NONE' or 'KMS'"
}

variable "kms_key_id" {
  type        = string
  default     = null
  description = "KMS CMK Key ID"
}

variable "shard_level_metrics" {
  description = "Enable Shard Level Metrics"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "autoscaling_enabled" {
  description = "Autoscaling of total number of shards according to CloudWatch metric"
  type        = bool
  default     = false
}
