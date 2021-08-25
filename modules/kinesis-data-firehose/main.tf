resource "aws_kinesis_firehose_delivery_stream" "this" {
  name = var.name
  kinesis_source_configuration {
    kinesis_stream_arn = var.kinesis_stream_arn
    role_arn = var.role_arn
  }
  destination = var.destination

  tags = merge(
    {
      "Name" : format("%s", var.name)
    },
    var.tags
  )
}