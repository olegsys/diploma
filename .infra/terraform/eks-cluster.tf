data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "diploma-vpc"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  tags = {
    Environment = "diploma"
  }

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-prod"
      instance_type                 = "t3.small"
      asg_desired_capacity          = 3
      asg_max_size                  = 5
      asg_min_size                  = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_prod.id]
    }
  ]
}

resource "aws_security_group" "worker_group_mgmt_prod" {
  name_prefix = "worker_group_mgmt_prod"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "kubernetes_secret" "docker-cfg" {
  metadata {
    name = "docker-cfg"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          auth = "${base64encode("${var.registry_username}:${var.registry_password}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}
resource "kubernetes_secret" "docker-cfg-stage" {
  metadata {
    name = "docker-cfg"
    namespace = "stage"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          auth = "${base64encode("${var.registry_username}:${var.registry_password}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}
resource "kubernetes_namespace" "stage" {
  metadata {
    annotations = {
      name = "stage"
    }
    name = "stage"
  }
}
resource "kubernetes_namespace" "monitoring" {
  metadata {
    annotations = {
      name = "monitoring"
    }
    name = "monitoring"
  }
}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# ### OIDC config
data "tls_certificate" "cluster" {
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}
resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

#Create IAM policy for ingress ALB
resource "aws_iam_policy" "policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for ALB ingress"
  policy      = "${file("iam-policy.json")}"
}

module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 4"

  create_role = true
  role_name = "AmazonEKSLoadBalancerControllerRole"
  provider_url = aws_iam_openid_connect_provider.cluster.url
  role_policy_arns = [
    aws_iam_policy.policy.arn
  ]
  number_of_role_policy_arns = 1
}

# SA for ingress controller
resource "kubernetes_service_account" "aws-load-balancer-controller"{
  metadata {
    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
    name = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::573822807646:role/AmazonEKSLoadBalancerControllerRole"
    }
  }
}