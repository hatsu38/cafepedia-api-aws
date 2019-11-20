module "ssm_rails_master_key" {
  source          = "./parameters"
  ssm_path        = "/app/rails_master_key"
  ssm_description = "RAILS_MASTER_KEY"
}

module "ssm_db_name" {
  source          = "./parameters"
  ssm_path        = "/app/db_name"
  ssm_description = "DB_NAME"
}
module "ssm_db_user_name" {
  source          = "./parameters"
  ssm_path        = "/app/user_name"
  ssm_description = "DB_USER_NAME"
}
module "ssm_db_password" {
  source          = "./parameters"
  ssm_path        = "/app/db_password"
  ssm_description = "DB_PASSWORD"
}
module "ssm_db_host" {
  source          = "./parameters"
  ssm_path        = "/app/db_host"
  ssm_description = "DB_HOST"
}
module "ssm_db_port" {
  source          = "./parameters"
  ssm_path        = "/app/db_port"
  ssm_description = "DB_PORT"
}
