locals {
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 7, k + 3)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 7, k)]
  database_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 7, k + 6)]
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.1"

  name = var.cluster_name
  cidr = var.vpc_cidr
  

  azs                   = local.azs
  public_subnets        = local.public_subnets
  private_subnets       = local.private_subnets
  database_subnets      = local.database_subnets 

  public_subnet_suffix  = "SubnetPublic"
  private_subnet_suffix = "SubnetPrivate"
  database_subnet_suffix = "SubnetDatabase"

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${var.cluster_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${var.cluster_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${var.cluster_name}-default" }

  public_subnet_tags  = merge(local.tags, {
    "kubernetes.io/role/elb" = "1"
  })
  private_subnet_tags = merge(local.tags, {
    "karpenter.sh/discovery" = var.cluster_name
  })

  tags = local.tags
}


#resource "aws_security_group" "allow_db_connect" {
#  name        = "allow_db"
#  description = "Allow DB connection inbound traffic and all outbound traffic"
#  vpc_id      = module.vpc.vpc_id
#
#  tags = {
#    Name = "allow_db"
#  }
#}
#
#resource "aws_vpc_security_group_ingress_rule" "allow_vpc_traffic_ipv4" {
#  security_group_id = aws_security_group.allow_db_connect.id
#  cidr_ipv4         = var.vpc_cidr
#  ip_protocol       = "-1" # semantically equivalent to all ports
#}
#
#
#resource "aws_vpc_security_group_egress_rule" "allow_vpc_egress_ipv4" {
#  security_group_id = aws_security_group.allow_db_connect.id
#  cidr_ipv4         = "0.0.0.0/0"
#  ip_protocol       = "-1" # semantically equivalent to all ports
#}
