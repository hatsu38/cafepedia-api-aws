resource "aws_ssm_parameter" "rails_master_key" {
  name        = "/${var.service_name}/rails_master_key"
  value       = "uninitialized"
  type        = "SecureString"
  description = "RAILS_MASTER_KEY"
  tags = {
    Name = "/${var.service_name}-rails_master_key"
  }

  lifecycle {
    ignore_changes = [value]
  }
}
