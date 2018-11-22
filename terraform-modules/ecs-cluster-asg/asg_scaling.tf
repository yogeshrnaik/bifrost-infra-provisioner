resource "aws_autoscaling_policy" "main_scale_up" {
  name                   = "${local.identifier}-ScaleOut-allow-more-schedulable-containers"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "low_schedulable_containers" {
  alarm_name          = "${local.identifier}-Low-schedulable-containers"
  comparison_operator = "LessThanOrEqualToThreshold" // GreaterThanOrEqualToThreshold
  evaluation_periods  = "1"
  metric_name         = "SchedulableContainers"
  namespace           = "CUSTOM/ECS"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "1"

  dimensions {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  alarm_description = "This metric monitors number of schedulable containers"

  alarm_actions = [
    "${aws_autoscaling_policy.main_scale_up.arn}",
  ]
}

resource "aws_autoscaling_policy" "main_scale_down" {
  name                   = "${local.identifier}-ScaleIn-reduce-schedulable-containers"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "high_schedulable_containers" {
  alarm_name          = "${local.identifier}-High-schedulable-containers"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "SchedulableContainers"
  namespace           = "CUSTOM/ECS"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "3"

  dimensions {
    ClusterName = "${aws_ecs_cluster.cluster.name}"
  }

  alarm_description = "This metric monitors number of schedulable containers"

  alarm_actions = [
    "${aws_autoscaling_policy.main_scale_down.arn}",
  ]
}
