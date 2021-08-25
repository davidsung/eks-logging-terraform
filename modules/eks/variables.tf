// EKS
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnets" {
  description = "Subnet IDs for running EKS"
  type        = list(string)
}

variable "cluster_prefix" {
  description = "EKS Cluster Prefix"
  type        = string
  default     = "cluster"
}

variable "cluster_version" {
  description = "EKS Version"
  type        = string
  default     = "1.21"
}

variable "node_ami_type" {
  description = "EKS node ami type"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_disk_size" {
  description = "EKS node disk size in GB"
  type        = number
  default     = 50
}

variable "node_group_desired_capacity" {
  description = "EKS node group desired capacity"
  type        = number
  default     = 3
}

variable "node_group_min_capacity" {
  description = "EKS node group minimum capacity"
  type        = number
  default     = 3
}

variable "node_group_max_capacity" {
  description = "EKS node group maximum capacity"
  type        = number
  default     = 6
}

variable "node_group_instance_types" {
  description = "EKS node group instance type"
  type        = list(string)
  default     = ["m5.large"]
}

variable "node_group_capacity_type" {
  description = "EKS node group capacity type"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_k8s_labels" {
  description = "Labels apply to node group"
  type        = map(string)
  default     = {}
}

variable "enable_irsa" {
  description = "Enable IRSA"
  type        = bool
  default     = true
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "write_kubeconfig" {
  description = "Whether to write kubeconfig file in the current folder"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
