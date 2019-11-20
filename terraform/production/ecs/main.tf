### クラスター
resource "aws_ecs_cluster" "cafepedia-api_ecs_cluster" {
  name = local.service_name
}

### タスク定義のテンプレート
data "template_file" "ecs_task_definition_service" {
  template = file("./task_definision_service.tpl.json")
  vars = {
    tag-id    = var.tag-id
    rails-env = var.rails-env
  }
}
data "template_file" "ecs_task_definition_migration" {
  template = file("./task_definition_migration.tpl.json")
  vars = {
    tag-id    = var.tag-id
    rails-env = var.rails-env
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
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

### タスク定義
resource "aws_ecs_task_definition" "default" {
  family                = "${local.service_name}-service"
  network_mode          = "bridge"
  memory                = "512"
  cpu                   = "216"
  container_definitions = data.template_file.ecs_task_definition_service.rendered
  execution_role_arn    = module.ecs_task_execution_role.iam_role_arn
}

# resource "aws_ecs_task_definition" "cafepdia-api-migrate" {
#   family                = "cafepdia-api-migrate"
#   network_mode          = "bridge"
#   memory                = "512"
#   cpu                   = "216"
#   container_definitions = "${data.template_file.ecs_task_definition_migration.rendered}"
#   execution_role_arn    = "${module.ecs_task_execution_role.iam_role_arn}"
# }

### ECSサービス
resource "aws_ecs_service" "cafepedia-api-ecs-service" {
  name            = "${local.service_name}-ecs-service"
  cluster         = aws_ecs_cluster.cafepedia-api_ecs_cluster.arn
  desired_count   = 1
  launch_type     = "EC2"
  task_definition = aws_ecs_task_definition.default.arn
  load_balancer {
    target_group_arn = data.terraform_remote_state.target_group.outputs.target_group_arn
    container_name   = local.service_name
    container_port   = "3000"
  }
}

resource "aws_cloudwatch_log_group" "cafepedia-api" {
  name = local.service_name
}

