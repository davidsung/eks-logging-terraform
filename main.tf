module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.all.names
  private_subnets = [cidrsubnet(var.vpc_cidr, 3, 0), cidrsubnet(var.vpc_cidr, 3, 1), cidrsubnet(var.vpc_cidr, 3, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 3, 3), cidrsubnet(var.vpc_cidr, 3, 4), cidrsubnet(var.vpc_cidr, 3, 5)]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  enable_dns_hostnames = true

  tags = {
    Environment = var.environment
  }
}

module "kms" {
  source = "./modules/kms"

  key_alias = var.key_alias
}

module "eks" {
  source = "./modules/eks"

  cluster_prefix  = var.eks_cluster_prefix
  cluster_version = var.eks_cluster_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  node_group_desired_capacity = var.eks_node_group_desired_capacity
  node_group_max_capacity     = var.eks_node_group_max_capacity
  node_group_min_capacity     = var.eks_node_group_min_capacity

  node_group_instance_types = var.eks_node_group_instance_types
  node_group_capacity_type  = var.eks_node_group_capacity_type
  node_group_k8s_labels = {
    Environment = var.environment
  }

  enable_irsa  = var.eks_enable_irsa
  map_roles    = var.eks_map_roles
  map_users    = var.eks_map_users
  map_accounts = var.eks_map_accounts

  write_kubeconfig = var.eks_write_kubeconfig

  tags = {
    Environment = var.environment
  }
}

module "apps" {
  source = "./modules/apps"

  region                   = var.aws_region
  cluster_id               = module.eks.cluster_id
  cluster_oidc_issuer_url  = module.eks.cluster_oidc_issuer_url
  kinesis_stream_name      = module.stream.name
  kinesis_stream_arn       = module.stream.arn
  es_endpoint              = module.elasticsearch.es_domain_endpoint
  fluent_bit_mem_buf_limit = var.eks_fluent_bit_mem_buf_limit
  fluent_bit_log_level     = var.eks_fluent_bit_log_level
  logstash_image_tag       = var.logstash_image_tag
}

# Kinesis stream for buffering
module "stream" {
  source = "./modules/kinesis-auto-scaling/terraform"
}

# Amazon Elasticsearch for Indexing Log
module "elasticsearch" {
  source = "./modules/amazon-elasticsearch"

  domain_name           = var.es_domain
  elasticsearch_version = var.es_version
  vpc_id                = module.vpc.vpc_id
  vpc_subnet_ids        = module.vpc.private_subnets

  dedicated_master_enabled = var.es_dedicated_master_enabled
  dedicated_master_type    = var.es_dedicated_master_type
  dedicated_master_count   = var.es_dedicated_master_count

  instance_type           = var.es_instance_type
  instance_count          = var.es_instance_count
  zone_awareness_enabled  = var.es_zone_awareness_enabled
  availability_zone_count = var.es_availability_zone_count

  warm_enabled = var.es_warm_enabled
  warm_type    = var.es_warm_type
  warm_count   = var.es_warm_count

  ebs_volume_size            = var.es_volume_size
  ebs_volume_type            = var.es_volume_type
  encrypt_at_rest_enabled    = var.es_encrypt_at_rest_enabled
  encrypt_at_rest_kms_key_id = module.kms.key_id

  automated_snapshot_start_hour = var.es_automated_snapshot_start_hour

  create_iam_service_linked_role = var.es_create_iam_service_linked_role

  nginx_enabled    = true
  nginx_subnet_id  = module.vpc.public_subnets.0
  nginx_cidr_block = var.kibana_whitelist_cidr

  tags = {
    Environment = var.environment
  }
}

# Allow HTTPS from EKS node group to ES
resource "aws_security_group_rule" "ingress_allow_https_from_eks" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = module.eks.cluster_primary_security_group_id
  security_group_id        = module.elasticsearch.es_security_group_id
}
