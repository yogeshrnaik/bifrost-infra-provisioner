resource "aws_appautoscaling_target" "ecs_service_target" {
  count              = "${local.count}"
  min_capacity       = "${element(var.service_min_instances, count.index)}"
  max_capacity       = "${element(var.service_max_instances, count.index)}"
  resource_id        = "service/${var.cluster_name}/${element(aws_ecs_service.service.*.name, count.index)}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "memory_based_ecs_policy" {
  count              = "${local.count}"
  name               = "${var.cluster_name}-${element(aws_ecs_service.service.*.name, count.index)}-memory-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${element(aws_appautoscaling_target.ecs_service_target.*.resource_id, count.index)}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value       = 70
    scale_out_cooldown = 60
    scale_in_cooldown  = 120
    disable_scale_in   = false
  }
}
