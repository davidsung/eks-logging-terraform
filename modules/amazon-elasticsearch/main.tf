# Amazon Elasticsearch
# Network Security Boundary
resource "aws_security_group" "es" {
  name        = "elasticsearch-sg"
  description = "Network security boundary for controlling inbound traffic to ES clusters"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" : "elasticsearch-sg"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "ingress_allow_https_from_security_group_ids" {
  count                    = (var.inbound_security_group_id != null) ? 1 : 0
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.inbound_security_group_id
  security_group_id        = aws_security_group.es.id
}

resource "aws_security_group_rule" "ingress_allow_https_from_nginx_security_group_id" {
  count                    = var.nginx_enabled ? 1 : 0
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nginx.id
  security_group_id        = aws_security_group.es.id
}

resource "aws_security_group_rule" "ingress_allow_https_from_cidr_blocks" {
  count             = length(var.inbound_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.inbound_cidr_blocks
  security_group_id = aws_security_group.es.id
}

resource "aws_security_group_rule" "egress_allow_all_to_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.es.id
}

# IAM Access Policy
#TODO: add condition for public deployment
#      "Condition": {
#          "IpAddress": {"aws:SourceIp": "127.0.0.1/32"}
#      },
resource "aws_elasticsearch_domain_policy" "main" {
  domain_name = aws_elasticsearch_domain.this.domain_name

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "${aws_elasticsearch_domain.this.arn}/*"
    }
  ]
}
POLICIES
}

resource "aws_elasticsearch_domain" "this" {
  domain_name           = var.domain_name
  elasticsearch_version = var.elasticsearch_version

  advanced_options = var.advanced_options

  advanced_security_options {
    enabled                        = var.advanced_security_options_enabled
    internal_user_database_enabled = var.advanced_security_options_internal_user_database_enabled
    master_user_options {
      master_user_arn      = var.advanced_security_options_master_user_arn
      master_user_name     = var.advanced_security_options_master_user_name
      master_user_password = var.advanced_security_options_master_user_password
    }
  }

  dynamic "cognito_options" {
    for_each = var.cognito_auth_enabled ? [true] : []

    content {
      enabled          = true
      identity_pool_id = var.cognito_identity_pool_id
      role_arn         = var.cognito_role_arn
      user_pool_id     = var.cognito_user_pool_id
    }
  }

  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_iops
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest_enabled
    kms_key_id = var.encrypt_at_rest_kms_key_id
  }

  domain_endpoint_options {
    enforce_https       = var.domain_endpoint_options_enforce_https
    tls_security_policy = var.domain_endpoint_options_tls_security_policy
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_type
    dedicated_master_count   = var.dedicated_master_count
    warm_enabled             = var.warm_enabled
    warm_type                = var.warm_enabled ? var.warm_type : null
    warm_count               = var.warm_enabled ? var.warm_count : null
    zone_awareness_enabled   = var.zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [true] : []

      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  dynamic "vpc_options" {
    for_each = var.vpc_enabled && length(var.vpc_subnet_ids) > 0 ? [true] : []

    content {
      security_group_ids = [aws_security_group.es.id]
      subnet_ids         = var.vpc_subnet_ids
    }
  }

  log_publishing_options {
    enabled                  = var.log_publishing_index_slow_enabled
    cloudwatch_log_group_arn = var.log_publishing_index_slow_cloudwatch_log_group_arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    enabled                  = var.log_publishing_search_slow_enabled
    cloudwatch_log_group_arn = var.log_publishing_search_slow_cloudwatch_log_group_arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    enabled                  = var.log_publishing_es_application_enabled
    cloudwatch_log_group_arn = var.log_publishing_es_application_cloudwatch_log_group_arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    enabled                  = var.log_publishing_audit_enabled
    cloudwatch_log_group_arn = var.log_publishing_audit_cloudwatch_log_group_arn
    log_type                 = "AUDIT_LOGS"
  }

  tags = merge(
    {
      "Name" : format("%s", var.domain_name)
    },
    var.tags
  )

  # For VPC deployment, an IAM Service Linked Role is required
  depends_on = [aws_iam_service_linked_role.es]
}

resource "aws_iam_service_linked_role" "es" {
  count            = var.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "es.amazonaws.com"
}

# Public Nginx Instance for accessing Kibana inside VPC remotely
resource "aws_security_group" "nginx" {
  name        = "nginx-sg"
  description = "Network security boundary for controlling inbound traffic to Nginx"
  vpc_id      = var.vpc_id

  tags = merge(
    {
      "Name" : "nginx-sg"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "ingress_allow_https_from_nginx_cidr_block" {
  count             = var.nginx_cidr_block != null ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.nginx_cidr_block]
  security_group_id = aws_security_group.nginx.id
}

resource "aws_security_group_rule" "nginx_egress_allow_all_to_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nginx.id
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "nginx_instance_profile" {
  name = "nginx-instance-profile"
  role = aws_iam_role.nginx_instance_role.name
}

resource "aws_iam_role" "nginx_instance_role" {
  name               = "nginx-instance-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
         "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "AllowAssumeByEC2"
    }
  ]
}
POLICY
}

# IAM Policy with SSM Session Manager permission
# Reference: https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-create-iam-instance-profile.html
resource "aws_iam_policy" "ssm_policy" {
  name   = "SessionManagerPermissions"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSSM",
      "Action": [
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "nginx_instance_role_attachment" {
  policy_arn = aws_iam_policy.ssm_policy.arn
  role       = aws_iam_role.nginx_instance_role.name
}

resource "aws_instance" "nginx" {
  count                  = var.nginx_enabled ? 1 : 0
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.nginx_instance_type
  subnet_id              = var.nginx_subnet_id
  vpc_security_group_ids = [aws_security_group.nginx.id]
  key_name               = var.nginx_ssh_key_name
  iam_instance_profile   = aws_iam_instance_profile.nginx_instance_profile.name
  user_data = templatefile("${path.module}/templates/init.tpl", {
    dns_resolver     = cidrhost(data.aws_vpc.this.cidr_block, 2)
    es_endpoint      = aws_elasticsearch_domain.this.endpoint
    cognito_endpoint = var.cognito_endpoint
  })

  tags = merge(
    {
      "Name" : var.nginx_instance_name
    },
    var.tags
  )
}

# TODO: refactor cold storage options once PR of https://github.com/hashicorp/terraform-provider-aws/issues/19593 merged to master
resource "null_resource" "enable_es_cold_storage" {
  provisioner "local-exec" {
    command = "aws es update-elasticsearch-domain-config --domain-name ${aws_elasticsearch_domain.this.domain_name} --elasticsearch-cluster-config ColdStorageOptions={Enabled=True}"
  }
}