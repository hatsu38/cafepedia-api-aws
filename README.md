# カフェペディアAPIのTerraform
関連リンク(以下のサービスが乗っています)
https://github.com/hatsu38/cafepedia-api

ECRにPushされたImageのバージョンを指定してApply
```
terraform plan -var 'tag_id=○.○.○'
```
