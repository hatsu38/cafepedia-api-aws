### t3.small インスタンス
resource "aws_instance" "cafepedia-api" {
  ami                         = "ami-06c98c6fe6f20c437"
  instance_type               = "t3.small"
  key_name                    = local.service_name
  monitoring                  = true
  user_data                   = file("./user_data.sh")
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_1_id
  iam_instance_profile        = data.terraform_remote_state.vpc.outputs.aws_iam_instance_profile_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.aws_ec2_security_group_id
  ]

  tags = {
    Name = local.service_name
  }

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_size = "30"
    volume_type = "gp2"
  }
}

### EIP
resource "aws_eip" "eip" {
  instance = aws_instance.cafepedia-api.id
  vpc      = true
  tags = {
    Name = local.service_name
  }
}


### AWS Load Balancer
resource "aws_lb" "cafepedia-api" {
  name               = local.service_name
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    data.terraform_remote_state.vpc.outputs.aws_ec2_security_group_id
  ]
  subnets = [
    data.terraform_remote_state.vpc.outputs.public_subnet_1_id,
    data.terraform_remote_state.vpc.outputs.public_subnet_2_id
  ]
}

## ALBのターゲット
resource "aws_lb_target_group" "http" {
  name     = local.service_name
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
### ALBのリスナー
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.cafepedia-api.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.cafepedia-api.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = aws_lb_target_group.http.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.cafepedia-api.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.http.arn
    type             = "forward"
  }
}

resource "aws_route53_zone" "cafepedia-api" {
  name    = "api.cafepedia.jp"
  comment = "cafepedia-api-domain"
}

resource "aws_route53_record" "cafepedia-api" {
  zone_id = aws_route53_zone.cafepedia-api.zone_id
  name    = aws_route53_zone.cafepedia-api.name
  type    = "A"
  alias {
    name                   = aws_lb.cafepedia-api.dns_name
    zone_id                = aws_lb.cafepedia-api.zone_id
    evaluate_target_health = true
  }
}

### TLS証明書の有効期限は13か月です。
### TLS証明書の作成(ドメイン反映後)
resource "aws_acm_certificate" "cafepedia-api" {
  domain_name               = aws_route53_record.cafepedia-api.name
  subject_alternative_names = []
  # DNS検証を行うようにすることで自動更新することが可能であるため、検証をDNSに設定しています。
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "api.cafepedia.jp"
  }
}

# ### 検証用DNSレコード
resource "aws_route53_record" "cafepedia-api_certificate" {
  name    = aws_acm_certificate.cafepedia-api.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.cafepedia-api.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.cafepedia-api.domain_validation_options[0].resource_record_value]
  zone_id = aws_route53_zone.cafepedia-api.zone_id
  ttl     = 60
}
