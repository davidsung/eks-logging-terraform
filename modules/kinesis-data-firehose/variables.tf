variable "name" {}
variable "destination" {
  description = "one of [s3 extended_s3 redshift elasticsearch splunk http_endpoint]"
}
variable "kinesis_stream_arn" {}
variable "role_arn" {}
variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}