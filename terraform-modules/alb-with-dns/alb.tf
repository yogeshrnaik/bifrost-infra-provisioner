locals {
  unique = "${var.name}-${var.env}"
}

data "aws_vpc" "vpc" {
  tags {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet_ids" "vpc_public_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Type = "public"
  }
}

resource "aws_alb" "alb" {
  name            = "${local.unique}-alb"
  internal        = false
  security_groups = ["${aws_security_group.alb.id}"]
  subnets         = ["${data.aws_subnet_ids.vpc_public_subnet_ids.ids}"]
  idle_timeout    = 450

  tags {
    Name        = "${local.unique}"
    Environment = "${var.env}"
  }
}

resource "aws_alb_target_group" "alb_https_tg" {
  name     = "${local.unique}-default-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.vpc.id}"

  deregistration_delay = 60

  tags {
    Name        = "${local.unique}-default-tg"
    Environment = "${var.env}"
  }
}

resource "aws_alb_listener" "alb_https_listener" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_https_tg.arn}"
    type             = "forward"
  }
}
