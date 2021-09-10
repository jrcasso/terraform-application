terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
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

resource "aws_route53_zone" "app_zone" {
  name = "${var.name}.${data.terraform_remote_state.operations.outputs.hosted_zone.name}"

  tags = {
    ops = var.name
  }
}

resource "aws_route53_record" "operations_ns_for_app" {
  allow_overwrite = true
  name            = "${var.name}.${data.terraform_remote_state.operations.outputs.hosted_zone.name}"
  ttl             = 60
  type            = "NS"
  zone_id         = data.terraform_remote_state.operations.outputs.hosted_zone.id

  records = [
    aws_route53_zone.app_zone.name_servers[0],
    aws_route53_zone.app_zone.name_servers[1],
    aws_route53_zone.app_zone.name_servers[2],
    aws_route53_zone.app_zone.name_servers[3],
  ]
}
