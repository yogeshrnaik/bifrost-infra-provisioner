locals {
  count  = "${length(var.service_names)}"
  region = "us-east-1"
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  count             = "${local.count}"
  name_prefix       = "${var.cluster_name}-${element(var.service_names, count.index)}-logs"
  retention_in_days = 7
}

data "template_file" "container_definitions_json" {
  count    = "${local.count}"
  template = "${file("${path.module}/container-definitions.json.tpl")}"

  vars {
    service_name   = "${element(var.service_names, count.index)}"
    docker_image   = "${element(var.docker_images, count.index)}"
    memory         = "${element(var.service_memories, count.index)}"
    cpu            = "${element(var.service_cpus, count.index)}"
    container_port = 8080
    log_group      = "${element(aws_cloudwatch_log_group.ecs_log_group.*.name, count.index)}"
    region         = "${local.region}"
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  count                 = "${local.count}"
  family                = "${var.cluster_name}-${element(var.service_names, count.index)}"
  container_definitions = "${element(data.template_file.container_definitions_json.*.rendered, count.index)}"

  lifecycle {
    create_before_destroy = true
  }
}
