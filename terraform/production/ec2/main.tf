### t3.small インスタンス
resource "aws_instance" "app" {
  ami                         = "ami-06c98c6fe6f20c437"
  instance_type               = "t3.small"
  key_name                    = var.service_name
  monitoring                  = true
  user_data                   = file("./user_data.sh")
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_1_id
  iam_instance_profile        = data.terraform_remote_state.vpc.outputs.aws_iam_instance_profile_instance_role_name
  associate_public_ip_address = true

  vpc_security_group_ids = [
    data.terraform_remote_state.vpc.outputs.aws_security_group_app_id
  ]

  tags = {
    Name = var.service_name
  }

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_size = "30"
    volume_type = "gp2"
  }
  lifecycle {
    prevent_destroy = true
  }
}

### EIP
resource "aws_eip" "eip" {
  instance = aws_instance.app.id
  vpc      = true
  tags = {
    Name = var.service_name
  }
}
