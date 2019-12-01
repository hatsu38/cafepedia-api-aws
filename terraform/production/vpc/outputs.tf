output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

output "aws_iam_instance_profile_instance_role_name" {
  value = aws_iam_instance_profile.instance_role.name
}

output "aws_security_group_app_id" {
  value = aws_security_group.app.id
}

output "aws_security_group_db_id" {
  value = aws_security_group.db.id
}
