### VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = local.service_name
  }
}

# EC2インスタンスのパブリックサブネット
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
  tags = {
    Name = "${local.service_name}-public-1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
  tags = {
    Name = "${local.service_name}-public-2"
  }
}

# RDS用のプライベートサブネットを作成
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "${local.service_name}-db-private-1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "${local.service_name}-db-private-2"
  }
}

# RDSプライベートサブネットグループ
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "${local.service_name}-db-subnets"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
}

#インターネットゲートウェイ
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.service_name}-public"
  }
}

### パブリックサブネットのルートテーブル
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.service_name}-public"
  }
}

### ルート
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.internet_gateway.id
  destination_cidr_block = "0.0.0.0/0"
}

### パブリックサブネットとルートテーブルの紐付け
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}


### IAM role
resource "aws_iam_instance_profile" "instance_role" {
  name = "${local.service_name}-instance_role"
  role = aws_iam_role.instance_role.name
}

### カフェペディアをApplyするIAM Role
resource "aws_iam_role" "instance_role" {
  name               = "${local.service_name}-instance_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

### IAM Role Policy
resource "aws_iam_role_policy" "instance_role_policy" {
  name   = "instance_role_policy"
  role   = aws_iam_role.instance_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

### セキュリティグループ
# EC2インスタンスのセキュリティグループ
resource "aws_security_group" "ec2-security-group" {
  name        = "ec2-${local.service_name}"
  description = "ec2-sg-${local.service_name}"
  vpc_id      = aws_vpc.vpc.id
  tags = {
    Name = "ec2-${local.service_name}"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDSのセキュリティグループ
resource "aws_security_group" "db-security-group" {
  name        = "${local.service_name}-db"
  description = "DB-sg${local.service_name}"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    security_groups = [
      aws_security_group.ec2-security-group.id
    ]
  }
  tags = {
    Name = "${local.service_name}-db-security-group"
  }
}
