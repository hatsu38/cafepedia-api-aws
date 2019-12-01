### s3バケットにtfstateを保存
terraform {
  backend "s3" {
    bucket = "cafepedia-api"
    key    = "route53/public/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
