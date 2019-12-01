### TLS証明書の有効期限は13か月です。
### TLS証明書の作成(ドメイン反映後)
resource "aws_acm_certificate" "app" {
  domain_name               = data.terraform_remote_state.route53_public.outputs.aws_route53_zone_default_name
  subject_alternative_names = []
  # DNS検証を行うようにすることで自動更新することが可能であるため、検証をDNSに設定しています。
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = var.domain_name
  }
}

# ### 検証用DNSレコード
resource "aws_route53_record" "certificate" {
  name    = aws_acm_certificate.app.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.app.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.app.domain_validation_options[0].resource_record_value]
  zone_id = data.terraform_remote_state.route53_public.outputs.aws_route53_zone_default_zone_id
  ttl     = 60
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [aws_route53_record.certificate.fqdn]
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = data.terraform_remote_state.route53_public.outputs.aws_lb_default_arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.app.arn
  default_action {
    target_group_arn = data.terraform_remote_state.route53_public.outputs.aws_lb_target_group_http_arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = data.terraform_remote_state.route53_public.outputs.aws_lb_default_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
