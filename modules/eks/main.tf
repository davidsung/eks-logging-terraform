resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id  = var.vpc_id
  subnets = var.subnets

  node_groups_defaults = {
    ami_type  = var.node_ami_type
    disk_size = var.node_disk_size
  }

  node_groups = {
    default = {
      desired_capacity = var.node_group_desired_capacity
      max_capacity     = var.node_group_max_capacity
      min_capacity     = var.node_group_min_capacity

      instance_types = var.node_group_instance_types
      capacity_type  = var.node_group_capacity_type
      k8s_labels     = var.node_group_k8s_labels
    }
  }

  enable_irsa  = var.enable_irsa
  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts

  write_kubeconfig = var.write_kubeconfig

  tags = var.tags
}
