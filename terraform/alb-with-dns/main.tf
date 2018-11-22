terraform {
  required_version = "= 0.11.10"

  backend "s3" {
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "Terraform-Lock-Table"
  }
}

provider "aws" {
  region  = "us-east-1"
  version = "= 1.43.0"
}

provider "template" {
  version = "= 1.0"
}

provider "null" {
  version = "= 1.0"
}

data "aws_acm_certificate" "default_certificate" {
  domain      = "*.ecsworkshop2018.online"
  statuses    = ["ISSUED"]
  most_recent = true
}

module "elb_with_dns" {
  source              = "../../terraform-modules/alb-with-dns"
  vpc_name            = "${var.vpc_name}"
  certificate_arn     = "${data.aws_acm_certificate.default_certificate.arn}"
  hosted_zone         = "ecsworkshop2018.online."
  name                = "${var.unique_name}"
  dns_record_set_name = "${var.unique_name}-${var.env}.ecsworkshop2018.online"
  env                 = "${var.env}"
  weight              = "${var.weight}"
}
