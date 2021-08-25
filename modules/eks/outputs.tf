output "cluster_arn" {
  value = module.eks.cluster_arn
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

//output "cluster_endpoint" {
//  value = data.aws_eks_cluster.cluster.endpoint
//}
//
//output "cluster_ca_certificate" {
//  value = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
//}
//
//output "cluster_token" {
//  value = data.aws_eks_cluster_auth.cluster.token
//}

output "cluster_primary_security_group_id" {
  value = module.eks.cluster_primary_security_group_id
}
