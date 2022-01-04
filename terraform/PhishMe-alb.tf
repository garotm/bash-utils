resource "aws_alb" "PhishMe-dev" {
    idle_timeout    = 4000
    internal        = false
    name            = "PhishMe-dev"
    security_groups = ["sg-ec95e598"]
    subnets         = ["subnet-8cad41a3", "subnet-ba2d8a85", "subnet-e5c14381"]

    enable_deletion_protection = false

    tags {
        "Owner" = "DevOps"
        "Env"   = "develpment"
        "Name"  = "PhishMe-dev-alb"
        "Stack" = "dev"
    }
}
resource "aws_alb_listener" "PhishMe-dev" {
    load_balancer_arn = "${aws_alb.PhishMe-dev.arn}"
    port              = "80"
    protocol          = "HTTP"
    /* ssl_policy     = "ELBSecurityPolicy-2015-05"
    certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
    */
    default_action {
        target_group_arn = "${aws_alb_target_group.PhishMe-dev.arn}"
        type             = "forward"
    }
}