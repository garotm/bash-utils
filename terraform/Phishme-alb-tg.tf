resource "aws_alb_target_group" "PhishMe-dev" {
  name                 = "PhishMe-dev"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${var.aws_vpc}"
  deregistration_delay = "300"
  target_type          = "instance"
 
  health_check {
    healthy_threshold   = "5",
    interval            = "60",
    matcher             = "200-399",
    path                = "/",
    port                = "traffic-port",
    protocol            = "HTTP",
    timeout             = "5",
    unhealthy_threshold = "2", 
  }
}
resource "aws_alb_target_group_attachment" "PhishMe-dev" {
  target_group_arn = "${aws_alb_target_group.PhishMe-dev.arn}"
  #target_id        = ["${aws_instance.PhishMe-dev.*.id}"]
  target_id        = "${element(aws_instance.PhishMe-dev.*.id, count.index)}"
  port             = 80
  count            = 2
}