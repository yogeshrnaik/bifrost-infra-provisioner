data "aws_vpc" "vpc" {
  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_ecs_cluster" "cluster" {
  cluster_name = "${var.cluster_name}"
}

data "aws_alb" "alb" {
  name = "${var.alb_name}"
}

data "aws_alb_listener" "alb_https_listener" {
  load_balancer_arn = "${data.aws_alb.alb.arn}"
  port              = 443
}

resource "aws_lb_target_group" "target_group" {
  count                = "${local.count}"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${data.aws_vpc.vpc.id}"
  deregistration_delay = 30

  health_check {
    protocol            = "HTTP"
    path                = "${element(var.service_health_checks, count.index)}"
    matcher             = "200"
    interval            = "10"
    timeout             = "5"
    healthy_threshold   = "3"
    unhealthy_threshold = "10"
  }
}

resource "aws_alb_listener_rule" "listener_rule" {
  count = "${local.count}"

  "action" {
    target_group_arn = "${element(aws_lb_target_group.target_group.*.arn, count.index)}"
    type             = "forward"
  }

  "condition" {
    field  = "path-pattern"
    values = ["${element(var.service_contexts, count.index)}/*"]
  }

  listener_arn = "${data.aws_alb_listener.alb_https_listener.arn}"
}

resource "aws_ecs_service" "service" {
  count                              = "${local.count}"
  name                               = "${element(var.service_names, count.index)}"
  cluster                            = "${data.aws_ecs_cluster.cluster.id}"
  task_definition                    = "${element(aws_ecs_task_definition.task_definition.*.arn, count.index)}"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60

  load_balancer {
    target_group_arn = "${element(aws_lb_target_group.target_group.*.arn, count.index)}"
    container_name   = "${element(var.service_names, count.index)}"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = ["desired_count"]
  }
}
