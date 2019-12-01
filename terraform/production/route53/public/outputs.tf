output "aws_lb_default_arn" {
  value = aws_lb.default.arn
}

output "aws_route53_zone_default_name" {
  value = aws_route53_zone.default.name
}

output "aws_route53_zone_default_zone_id" {
  value = aws_route53_zone.default.zone_id
}

output "aws_lb_target_group_http_arn" {
  value = aws_lb_target_group.http.arn
}

