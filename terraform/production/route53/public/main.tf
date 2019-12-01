### ホストゾーン作成
resource "aws_route53_zone" "default" {
  name    = var.domain_name
  comment = var.domain_name
}

resource "aws_route53_record" "default" {
  zone_id = aws_route53_zone.default.zone_id
  name    = aws_route53_zone.default.name
  type    = "A"
  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}

### AWS Load Balancer
resource "aws_lb" "default" {
  name               = var.service_name
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    data.terraform_remote_state.vpc.outputs.aws_security_group_app_id
  ]
  subnets = [
    data.terraform_remote_state.vpc.outputs.public_subnet_1_id,
    data.terraform_remote_state.vpc.outputs.public_subnet_2_id
  ]
}

## ALBのターゲットグループ
resource "aws_lb_target_group" "http" {
  name     = var.service_name
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.vpc.outputs.vpc_id
  health_check {
    interval            = 30
    path                = "/health_check"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}
