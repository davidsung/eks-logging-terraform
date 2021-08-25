# KMS CMK Key
resource "aws_kms_key" "key" {
  tags = var.tags
}

resource "aws_kms_alias" "logging_key_alias" {
  name          = format("alias/%s", var.key_alias)
  target_key_id = aws_kms_key.key.key_id
}
