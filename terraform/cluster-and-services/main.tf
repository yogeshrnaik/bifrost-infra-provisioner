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
  asg_min_size  = "${var.min_instances}"
  asg_max_size  = "${var.max_instances}"
  vpc_name      = "${var.vpc_name}"
  alb_name      = "${var.alb_name}"
  env           = "${var.env}"
}

module "service" {
  source                = "../../terraform-modules/service"
  cluster_name          = "${module.ecs_cluster.cluster_name}"
  service_names         = ["${var.service_names}"]
  service_contexts      = ["${var.service_contexts}"]
  service_health_checks = ["${var.service_health_checks}"]
  service_cpus          = ["${var.service_cpus}"]
  service_memories      = ["${var.service_memories}"]
  service_min_instances = "${var.service_min_instances}"
  service_max_instances = "${var.service_max_instances}"
  docker_images         = ["${var.docker_images}"]
  vpc_name              = "${var.vpc_name}"
  alb_name              = "${var.alb_name}"
}
