variable "vpc_name" {}

variable "alb_name" {}

variable "cluster_name" {}

variable "service_names" {
  type = "list"
}

variable "service_contexts" {
  type = "list"
}

variable "service_health_checks" {
  type = "list"
}

variable "docker_images" {
  type = "list"
}

variable "service_memories" {
  type = "list"
}

variable "service_cpus" {
  type = "list"
}

variable "service_min_instances" {
  type = "list"
}

variable "service_max_instances" {
  type = "list"
}
