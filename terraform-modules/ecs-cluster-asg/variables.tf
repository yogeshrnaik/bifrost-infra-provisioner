variable "unique_name" {}

variable "cluster_name" {}

variable "instance_type" {}

variable "vpc_name" {}

variable "alb_name" {}

variable "env" {}

variable "asg_min_size" {
  default = 1
}

variable "asg_max_size" {
  default = 5
}
