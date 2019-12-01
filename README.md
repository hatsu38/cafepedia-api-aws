# カフェペディアAPIのTerraform

## Terraformのインストール
```
brew install tfenv
tfenv install
```

## 設定手順
```
cat << EOS > .aws_credentials
[cafepedia-api-tf]
aws_access_key_id     = AKXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
aws_default_region    = ap-northeast-1
EOS

export AWS_SHARED_CREDENTIALS_FILE="/path/to/.aws-credentials"
export AWS_PROFILE="cafepedia-api-tf"

aws s3 ls # 認証エラーなく正常に動作すること
```

## Terraformのセットアップ
terraformのaws providerをダウンロードする
```
cd terraform/production/ecs/

terraform init
```

## 普段の操作
```
# main.tfがあるフォルダで下記のコマンドが実行できる。

terraform validate

terraform fmt

terraform plan

# ecs フォルダ以下のみ、下記のパラメータの指定が必要。
# tag_id : docker imageのタグ
terraform plan -var 'tag_id=0.0.1'
```
