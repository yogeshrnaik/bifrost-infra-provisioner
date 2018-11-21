locals {
  identifier = "${var.unique_name}-${var.env}-${var.cluster_name}"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${local.identifier}"
}
