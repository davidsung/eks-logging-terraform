provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = var.prometheus_namespace
  create_namespace = var.create_prometheus_namespace

  values = [
    "${file("${path.module}/logstash/logstash-override-values.yaml")}"
  ]

  set {
    name  = "grafana.dashboardProviders.dashboardproviders\\.yaml.apiVersion"
    value = "1"
  }

  set {
    name  = "grafana.dashboardProviders.dashboardproviders\\.yaml.providers[0].orgId"
    value = "1"
  }

  set {
    name  = "grafana.dashboardProviders.dashboardproviders\\.yaml.providers[0].type"
    value = "file"
  }

  set {
    name  = "grafana.dashboardProviders.dashboardproviders\\.yaml.providers[0].disableDeletion"
    value = "false"
  }

  set {
    name  = "grafana.dashboardProviders.dashboardproviders\\.yaml.providers[0].options.path"
    value = "/var/lib/grafana/dashboards/default"
  }

  set {
    name  = "grafana.dashboards.default.logging.gnetId"
    value = "7752"
  }

  set {
    name  = "grafana.dashboards.default.logging.revision"
    value = "3"
  }

  set {
    name  = "grafana.dashboards.default.logging.datasource"
    value = "Prometheus"
  }

  set {
    name  = "prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues"
    value = "False"
  }
}

resource "helm_release" "fluent_bit" {
  name       = "aws-for-fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"

  namespace = var.fluent_bit_namespace

  set {
    name  = "input.memBufLimit"
    value = var.fluent_bit_mem_buf_limit
  }

  set {
    name  = "cloudWatch.enabled"
    value = "false"
  }

  set {
    name  = "firehose.enabled"
    value = "false"
  }

  set {
    name  = "elasticsearch.enabled"
    value = "false"
  }

  set {
    name  = "kinesis.enabled"
    value = "true"
  }

  set {
    name  = "kinesis.region"
    value = var.region
  }

  set {
    name  = "kinesis.stream"
    value = var.kinesis_stream_name
  }

  set {
    name  = "kinesis.replaceDots"
    value = "_"
  }

  set {
    name  = "kinesis.partitionKey"
    value = var.fluent_bit_output_kinesis_partition_key
  }

  set {
    name  = "kinesis.aggregation"
    value = var.fluent_bit_output_kinesis_aggregation
  }

  set {
    name  = "serviceAccount.name"
    value = var.fluent_bit_service_account_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.fluent_bit_irsa.iam_role_arn
    type  = "string"
  }

  set {
    name  = "env[0].name"
    value = "FLB_LOG_LEVEL"
  }

  set {
    name  = "env[0].value"
    value = var.fluent_bit_log_level
  }
}

resource "kubernetes_deployment" "log_generator" {
  metadata {
    name = "log-generator"
    labels = {
      "app.kubernetes.io/name" = "log-generator"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "log-generator"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "log-generator"
        }
      }

      spec {
        container {
          image = "banzaicloud/log-generator:0.3.2"
          name  = "log-generator"
          command = [
            "/loggen"
          ]
          args = [
            "--event-per-sec=1000",
          ]

          resources {
            requests = {
              cpu    = "1500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

provider "docker" {
  registry_auth {
    address  = local.ecr_address
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "docker_registry_image" "this" {
  name = local.ecr_image_name

  build {
    context    = "${path.module}/logstash"
    dockerfile = "Dockerfile"
  }
}

resource "aws_ecr_repository" "this" {
  name                 = var.logstash_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

//resource "helm_release" "logstash" {
//  name       = "logstash"
//  repository = "https://helm.elastic.co"
//  chart      = "logstash"
//
//  namespace        = var.logstash_namespace
//  create_namespace = var.create_logstash_namespace
//
//  set {
//    name  = "image"
//    value = local.ecr_repo_url
//  }
//
//  set {
//    name  = "imageTag"
//    value = local.logstash_image_tag
//  }
//
//  set {
//    name  = "rbac.create"
//    value = "true"
//  }
//
//  set {
//    name  = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
//    value = module.logstash_irsa.iam_role_arn
//  }
//
//  set {
//    name  = "extraEnvs[0].name"
//    value = "AWS_REGION"
//  }
//
//  set {
//    name  = "extraEnvs[0].value"
//    value = var.region
//  }
//
//  set {
//    name  = "extraEnvs[1].name"
//    value = "KINESIS_STREAM_NAME"
//  }
//
//  set {
//    name  = "extraEnvs[1].value"
//    value = var.kinesis_stream_name
//  }
//
//  set {
//    name  = "extraEnvs[2].name"
//    value = "ES_ENDPOINT"
//  }
//
//  set {
//    name  = "extraEnvs[2].value"
//    value = var.es_endpoint
//  }
//}
