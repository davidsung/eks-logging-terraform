module "fluent_bit_irsa" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = "aws-for-fluent-bit"
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.fluent_bit.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.fluent_bit_namespace}:${var.fluent_bit_service_account_name}"]
}

resource "aws_iam_policy" "fluent_bit" {
  name_prefix = "fluent-bit"
  description = "EKS fluent-bit policy for cluster ${var.cluster_id}"
  policy      = data.aws_iam_policy_document.fluent_bit.json
}

data "aws_iam_policy_document" "fluent_bit" {
  statement {
    sid    = "StmtKinesisStream"
    effect = "Allow"

    actions = [
      "kinesis:DescribeStream",
      "kinesis:PutRecord",
      "kinesis:PutRecords",
      "kinesis:ListShards",
      "kinesis:RegisterStreamConsumer",
    ]

    resources = [var.kinesis_stream_arn]
  }

  statement {
    sid    = "StmtKinesisShard"
    effect = "Allow"

    actions = [
      "kinesis:SubscribeToShard",
      "kinesis:DescribeStreamConsumer",
    ]

    resources = ["${var.kinesis_stream_arn}/*"]
  }
}

module "logstash_irsa" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  create_role                   = true
  role_name                     = "logstash"
  provider_url                  = replace(var.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.logstash.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.logstash_namespace}:${var.logstash_service_account_name}"]
}

resource "aws_iam_policy" "logstash" {
  name_prefix = "logstash"
  description = "EKS logstash policy for cluster ${var.cluster_id}"
  policy      = data.aws_iam_policy_document.logstash.json
}

data "aws_iam_policy_document" "logstash" {
  statement {
    sid    = "StmtLogstashKinesis"
    effect = "Allow"

    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards",
    ]

    resources = [var.kinesis_stream_arn]
  }

  statement {
    sid    = "StmtlogstashDynamoDB"
    effect = "Allow"

    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
    ]

    resources = ["arn:aws:dynamodb:${var.region}:${local.account_id}:table/logstash"]
  }

  statement {
    sid    = "StmtCloudWatch"
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "logstashAESPolicy"
    effect = "Allow"

    actions = [
      "es:*",
    ]

    resources = [var.kinesis_stream_arn]
  }
}