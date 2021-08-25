resource "aws_kinesis_stream" "this" {
  name                = var.name
  shard_count         = var.shard_count
  retention_period    = var.retention_period
  encryption_type     = var.encryption_type
  kms_key_id          = var.kms_key_id
  shard_level_metrics = var.shard_level_metrics
  tags = merge(
    {
      "Name" : format("%s", var.name)
    },
    var.tags
  )

  #WIP: remove lifecycle after proper KMS
  lifecycle {
    ignore_changes = [kms_key_id]
  }
}
