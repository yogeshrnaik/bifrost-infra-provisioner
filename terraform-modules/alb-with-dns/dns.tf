data "aws_route53_zone" "hosted_zone" {
  name         = "${var.hosted_zone}"
  private_zone = false
}

resource "aws_cloudformation_stack" "application-dns" {
  name          = "${local.unique}-alb-dns"
  template_body = "${file("${path.module}/dns_name.yaml")}"

  parameters {
    HostedZoneId             = "${data.aws_route53_zone.hosted_zone.id}"
    DNSName                  = "${var.dns_record_set_name}"
    LoadBalancerHostedZoneId = "${aws_alb.alb.zone_id}"
    LoadBalancerDNSName      = "dualstack.${aws_alb.alb.dns_name}"
    Identifier               = "${local.unique}"
    Weight                   = "${var.weight}"
  }
}
