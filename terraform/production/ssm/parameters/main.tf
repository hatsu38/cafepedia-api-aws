resource "aws_ssm_parameter" "default" {
  name        = "${var.ssm_path}"
  value       = "uninitialized"
  type        = "SecureString"
  description = "${var.ssm_description}"
  tags = {
    Name = "${var.ssm_path}"
  }

  lifecycle {
    ignore_changes = [value]
  }
}