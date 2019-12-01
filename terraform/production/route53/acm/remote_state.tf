data "terraform_remote_state" "route53_public" {
  backend = "s3"

  config = {
    bucket = "cafepedia-api"
    key    = "route53/public/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
