### クラスター
resource "aws_ecs_cluster" "default" {
  name = var.service_name
}

### タスク定義のテンプレート
data "template_file" "ecs_task_definition_service" {
  template = file("./task_definition_service.tpl.json")
  vars = {
    service_name = var.service_name
    ecr_url      = var.ecr_url
    tag_id       = var.tag_id
    rails_env    = var.rails_env
  }
}
data "template_file" "ecs_task_definition_migration" {
  template = file("./task_definition_migrate.tpl.json")
  vars = {
    service_name = var.service_name
    ecr_url      = var.ecr_url
    tag_id       = var.tag_id
    rails_env    = var.rails_env
  }
}

### SSMを使用するタスクのIAMロールポリシー
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}
module "ecs_task_execution_role" {
  source     = "./iam/"
  name       = "${var.service_name}-ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

### タスク定義
resource "aws_ecs_task_definition" "default" {
  family                = "${var.service_name}-service"
  network_mode          = "bridge"
  memory                = "512"
  cpu                   = "216"
  container_definitions = data.template_file.ecs_task_definition_service.rendered
  execution_role_arn    = module.ecs_task_execution_role.iam_role_arn
}

# resource "aws_ecs_task_definition" "migrate" {
#   family                = "${var.service_name}-migrate"
#   network_mode          = "bridge"
#   memory                = "512"
#   cpu                   = "216"
#   container_definitions = "${data.template_file.ecs_task_definition_migration.rendered}"
#   execution_role_arn    = "${module.ecs_task_execution_role.iam_role_arn}"
# }

### ECSサービス
resource "aws_ecs_service" "default" {
  name            = "${var.service_name}-ecs-service"
  cluster         = aws_ecs_cluster.default.arn
  desired_count   = 1
  launch_type     = "EC2"
  task_definition = aws_ecs_task_definition.default.arn
  load_balancer {
    target_group_arn = data.terraform_remote_state.route53_public.outputs.aws_lb_target_group_http_arn
    container_name   = var.service_name
    container_port   = "3000"
  }
}

resource "aws_cloudwatch_log_group" "cafepedia-api" {
  name = var.service_name
}

