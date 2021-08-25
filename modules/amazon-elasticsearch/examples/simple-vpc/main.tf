locals {
  vpc_name  = "elasticsearch-vpc"
  vpc_cidr  = "10.0.0.0/16"
  es_domain = "elasticsearch"
  env       = "dev"
}

data "aws_availability_zones" "all" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = vpc_name
  cidr = vpc_cidr

  azs             = data.aws_availability_zones.all.names
  private_subnets = [cidrsubnet(vpc_cidr, 3, 0), cidrsubnet(vpc_cidr, 3, 1), cidrsubnet(vpc_cidr, 3, 2)]
  public_subnets  = [cidrsubnet(vpc_cidr, 3, 3), cidrsubnet(vpc_cidr, 3, 4), cidrsubnet(vpc_cidr, 3, 5)]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  enable_dns_hostnames = true

  tags = {
    Environment = env
  }
}

module "elasticsearch" {
  source = "../../"

  domain_name    = es_domain
  vpc_id         = module.vpc.vpc_id
  vpc_subnet_ids = [module.vpc.private_subnets.0]

  create_iam_service_linked_role = true

  nginx_enabled    = true
  nginx_subnet_id  = module.vpc.public_subnets.0
  nginx_cidr_block = "1.2.3.4/32" # IP CIDR where you want to access the kibana

  tags = {
    Environment = env
  }
}
