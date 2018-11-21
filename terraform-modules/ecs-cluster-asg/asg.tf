data "aws_subnet_ids" "vpc_public_subnet_ids" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    Type = "public"
  }
}

resource aws_autoscaling_group "asg" {
  name_prefix               = "${local.identifier}-asg"
  min_size                  = "${var.asg_min_size}"
  max_size                  = "${var.asg_max_size}"
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_configuration      = "${aws_launch_configuration.launch_config.name}"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.vpc_public_subnet_ids.ids}"]
  default_cooldown          = 300

  initial_lifecycle_hook {
    name                 = "asg-drain-before-terminate-hook"
    default_result       = "CONTINUE"
    heartbeat_timeout    = "180"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"

    notification_metadata = <<EOF
    {
      "cluster-name": "${aws_ecs_cluster.cluster.name}"
    }
    EOF

    //notification_target_arn = "${var.ecs_asg_drain_container_instances_lambda_events_queue}"
    //role_arn = "${aws_iam_role.ecs_asg_notification_access_role.arn}"
  }

  enabled_metrics = [
    "GroupStandbyInstances",
    "GroupTotalInstances",
    "GroupPendingInstances",
    "GroupTerminatingInstances",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMinSize",
    "GroupMaxSize",
  ]

  tag {
    key                 = "Name"
    value               = "${local.identifier}-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Description"
    value               = "EC2 ASG for ${local.identifier} ECS cluster"
    propagate_at_launch = true
  }

  timeouts {
    delete = "20m"
  }
}

resource "null_resource" "rotate_asg_instances" {
  triggers {
    launch_configuration = "${aws_launch_configuration.launch_config.id}"
  }

  depends_on = ["aws_autoscaling_group.asg"]

  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/roll_asg_instances.py ${aws_autoscaling_group.asg.name}"
  }
}
