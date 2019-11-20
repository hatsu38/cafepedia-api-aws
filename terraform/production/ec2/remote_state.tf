data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "cafepedia-api"
    key    = "vpc/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
