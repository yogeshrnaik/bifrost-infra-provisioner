variable "vpc_name" {}

variable "name" {}

variable "env" {}

variable "certificate_arn" {}

variable "alb_access_cidr_blocks" {
  type    = "list"
  default = ["0.0.0.0/0"]
}

variable "alb_access_ipv6_cidr_blocks" {
  type    = "list"
  default = ["::/0"]
}

variable "weight" {}

variable "hosted_zone" {}

variable "dns_record_set_name" {}
