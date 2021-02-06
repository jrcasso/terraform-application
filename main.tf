terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "terraform-applications"
    key    = "mean-demo/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  profile = "personal"
  region  = "us-east-1"
}

data "terraform_remote_state" "operations" {
  backend = "s3"
  config = {
    bucket = "terraform-operations"
    key    = "${var.operation}/terraform.tfstate"
    region = "us-east-1"
  }
}

locals {
  vpc_id = var.operation == "stage" ? data.terraform_remote_state.operations.outputs.stage_vpc_id : data.terraform_remote_state.operations.outputs.prod_vpc_ids
  sg_ids = var.operation == "stage" ? data.terraform_remote_state.operations.outputs.stage_sg_ids : data.terraform_remote_state.operations.outputs.prod_sg_ids
  hosted_zone = var.operation == "stage" ? data.terraform_remote_state.operations.outputs.stage_hosted_zone : data.terraform_remote_state.operations.outputs.prod_hosted_zone
}

resource "aws_route53_zone" "app_zone" {
  name = "${var.name}.${local.hosted_zone.name}"

  tags = {
    env = var.name
  }
}

resource "aws_route53_record" "operations_ns_for_app" {
  allow_overwrite = true
  name            = "${var.name}.${local.hosted_zone.name}"
  ttl             = 60
  type            = "NS"
  zone_id         = local.hosted_zone.id

  records = [
    aws_route53_zone.app_zone.name_servers[0],
    aws_route53_zone.app_zone.name_servers[1],
    aws_route53_zone.app_zone.name_servers[2],
    aws_route53_zone.app_zone.name_servers[3],
  ]
}
