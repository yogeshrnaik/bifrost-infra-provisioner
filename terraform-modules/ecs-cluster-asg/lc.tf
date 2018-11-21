data "aws_vpc" "vpc" {
  tags {
    Name = "${var.vpc_name}"
  }
}

resource aws_launch_configuration "launch_config" {
  name_prefix          = "${local.identifier}"
  image_id             = "ami-07eb698ce660402d2"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins_instance_profile.name}"

  security_groups = ["${aws_security_group.ec2_sg.id}"]

  key_name = "${aws_key_pair.ssh_key.key_name}"

  user_data = <<-EOF
              #!/bin/bash
              ${data.template_file.user_data_ecs_cluster_part.rendered}
              EOF

  lifecycle = {
    create_before_destroy = "true"
  }

  root_block_device {
    // Recommended for ECS AMI https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-ami-storage-config.html
    volume_size           = "30"
    delete_on_termination = true
  }
}

data "template_file" "user_data_ecs_cluster_part" {
  template = "${file("${path.module}/user_data_ecs_cluster_part.tpl")}"

  vars {
    cluster_name = "${aws_ecs_cluster.cluster.name}"
  }
}

data "aws_alb" "alb" {
  name = "${var.alb_name}"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${local.identifier}-ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC08HTZw5HR0hkzxPe03aghKp5ZAI0U1JaPsevIgQiJSlH2ILo0IXV+LqJ9G7RPtMWjsw2gCz0GticFp7EoY2wcS25s4HCdsVHM5iXFTr/1RPPlTOxiOZkZI6rOE8EsuqQ9JAY1Njzc+NzchPvnFo+mOUVaZRh88AklK2WMEA8/SMVzn/m9hZhQPvFke2IIfrGCaSrhbsQgyHuCqv1exX4s//C7b3HMf8vlmtLEwqX+UUdCy8vkJqlsOJHdGUvezxZabWjqOWjOy3DZQCwJzVva48P6uy8jHSvrVGghstuYbw8OHhbmG5enFUTYvf1nJwrzWWePnYvarI5aR9Z0jTrfKf5v5lUEpv0cqo6syhpsEyNYo0lduh2YD7GwV94lpFZiInQtxnwIby+PU2TxV/7BBwQV48wXQA6UcyCV5J0Vb2Q+ZbkzFNRW4TKbGrUJnzwjqno9vHeYTZzcyZ1BMQ1kk3rrH40e27SQZT9AaWFn2nO9lOH7smz0v/XRTdjEabxNMG09VaXVktSc8o3AAnlgLdexKZmQbo2FhllKLV482UM5VxH04ebUxkv5qMOl6v4KjMyy3A1kfFYvNXsox7jLBzx2AQReq6h7HWxuSuRieCM6uo/lItVbrWjPFCgAtoFfrfWLwOFH/ofQgghmT7KlurL4hXEOq6BAaB+ElUqgEQ== kaushik.c02@gmail.com"
}

resource "aws_security_group" "ec2_sg" {
  name_prefix = "${local.identifier}-ec2-sg"
  description = "${local.identifier} cluster instances security group"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags {
    Name = "${local.identifier}-ec2-sg"
  }
}

resource "aws_security_group_rule" "ec2_ingress_ephemeral_port_range_tcp_alb_access" {
  from_port                = 31000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.ec2_sg.id}"
  to_port                  = 61000
  type                     = "ingress"
  source_security_group_id = "${element(data.aws_alb.alb.security_groups, 0)}"
}

resource "aws_security_group_rule" "ec2_ingress_ssh_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.ec2_sg.id}"
  to_port           = 22
  type              = "ingress"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}
