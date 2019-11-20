output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_subnet_2.id
}

output "aws_iam_instance_profile_name" {
  value = aws_iam_instance_profile.instance_role.name
}

output "aws_ec2_security_group_id" {
  value = aws_security_group.ec2-security-group.id
}

output "aws_db_security_group_id" {
  value = aws_security_group.db-security-group.id
}
