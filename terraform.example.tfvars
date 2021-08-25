environment = "staging"

// KMS
key_alias = "logging"

// VPC
vpc_name = "vpc"
vpc_cidr = "10.0.0.0/16"

// EKS
eks_node_group_capacity_type    = "SPOT"
eks_node_group_instance_types   = ["m5.8xlarge", "c5.9xlarge", "r5.8xlarge"]
eks_node_group_desired_capacity = 1
eks_node_group_max_capacity     = 3
eks_node_group_min_capacity     = 1

// Fluentbit
eks_fluent_bit_mem_buf_limit = "100MB"

// Kinesis
kinesis_stream_shard_count      = 1
kinesis_stream_retention_period = 72

// Amazon Elastic
es_domain                   = "logging"
es_dedicated_master_enabled = true
es_dedicated_master_count   = 3
es_dedicated_master_type    = "c6g.large.elasticsearch"
es_availability_zone_count  = 3
es_instance_count           = 3
es_instance_type            = "r6g.xlarge.elasticsearch"
es_warm_enabled             = true
es_warm_type                = "ultrawarm1.medium.elasticsearch"
es_warm_count               = 2
es_zone_awareness_enabled   = true
es_volume_type              = "gp2"
es_volume_size              = 500
# kibana_whitelist_cidr       = "a.b.c.d/e"
