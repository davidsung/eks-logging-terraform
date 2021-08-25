variable "key_alias" {
  type    = string
  default = "logging"
}

variable "tags" {
  type    = map(string)
  default = {}
}
