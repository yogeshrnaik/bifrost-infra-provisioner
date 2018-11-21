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

module "ecs_cluster" {
  source        = "../../terraform-modules/ecs-cluster-asg"
  unique_name   = "${var.unique_name}"
  cluster_name  = "${var.cluster_name}"
  instance_type = "${var.instance_type}"
  vpc_name      = "${var.vpc_name}"
  alb_name      = "${var.alb_name}"
  env           = "${var.env}"
}
