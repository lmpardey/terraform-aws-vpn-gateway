provider "aws" {
  region = "eu-west-1"
}

module "vpn_gateway" {
  source = "../../"

  vpn_gateway_id      = module.vpc.vgw_id
  customer_gateway_id = aws_customer_gateway.main.id

  vpc_id                       = module.vpc.vpc_id
  vpc_subnet_route_table_ids   = module.vpc.private_route_table_ids
  vpc_subnet_route_table_count = length(var.vpc_private_subnets)
  local_ipv4_network_cidr      = "0.0.0.0/0"
  remote_ipv4_network_cidr     = module.vpc.vpc_cidr_block
}

resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = "172.83.124.10"
  type       = "ipsec.1"

  tags = {
    Name = "complete-vpn-gateway"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "complete-vpn-gateway"

  cidr = "10.10.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  private_subnets = var.vpc_private_subnets

  enable_nat_gateway = false

  enable_vpn_gateway = true

  tags = {
    Owner       = "user"
    Environment = "staging"
    Name        = "complete"
  }
}
