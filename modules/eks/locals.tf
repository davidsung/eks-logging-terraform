locals {
  cluster_name = "${var.cluster_prefix}-${random_string.suffix.result}"
}
