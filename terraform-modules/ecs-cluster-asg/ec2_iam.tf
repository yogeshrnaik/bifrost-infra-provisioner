resource "aws_iam_role" "instance_ec2_role" {
  name = "${local.identifier}-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_service_role" {
  role       = "${aws_iam_role.instance_ec2_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "jenkins_instance_profile" {
  name = "${aws_iam_role.instance_ec2_role.name}"
  role = "${aws_iam_role.instance_ec2_role.name}"
}

resource "aws_iam_role" "ecs_asg_notification_access_role" {
  name = "${local.identifier}-notification-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "asg_notification_access" {
  role       = "${aws_iam_role.ecs_asg_notification_access_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRole"
}
