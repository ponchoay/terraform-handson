# 第 7 章（任意）HCP Terraform で state を共有する

## 要約

state の保存先をローカルファイルから HCP Terraform（HashiCorp のマネージドサービス、無料プランあり）に移し、複数人が同じ state を安全に使える形にします。`terraform.tf` に `cloud` ブロックを足して `terraform init` するだけで移行でき、ロックと実行履歴が自動で付きます（約 30 分）。第 6 章で削除した後の状態から始めます。

## この章のゴール

- `cloud` ブロックで state をリモートに置ける
- ローカル state のままチーム開発すると何が困るかを説明できる

## 手順

1. https://app.terraform.io でアカウントを作り、Organization を作成する（名前は全世界で一意。以下 `<ORG名>` と書く）
2. CLI からログインする（ブラウザでトークンを発行し、ターミナルに貼り付ける）

   ```shell
   terraform login
   ```

3. `terraform.tf` の `terraform` ブロック内に `cloud` ブロックを追加する

   ```hcl
   terraform {
     cloud {
       organization = "<ORG名>"

       workspaces {
         name = "learn-terraform-aws"
       }
     }

     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.92"
       }
     }

     required_version = ">= 1.2"
   }
   ```

4. 初期化する（state を移行するか聞かれたら `yes`。HCP Terraform 上に Workspace `learn-terraform-aws` が作られる）

   ```shell
   terraform init
   ```

5. HCP Terraform の画面で Workspace `learn-terraform-aws` を開き、Settings → General → Execution Mode を `Local` にして保存する（`plan` / `apply` は手元で実行し、state だけを HCP Terraform に置く設定）
6. 適用する（`yes` と入力。第 6 章で削除したリソースが作り直される）

   ```shell
   terraform apply
   ```

7. HCP Terraform の Workspace 画面の States タブで、state のバージョンが記録されていることを確認する
8. ローカルに残った古い state ファイルを削除する

   ```shell
   rm -f terraform.tfstate terraform.tfstate.backup
   ```

9. 終了するときは削除する（`yes` と入力）

   ```shell
   terraform destroy
   ```

Execution Mode を既定の `Remote` のままにすると、`plan` / `apply` は HCP Terraform 上で実行されるため、AWS の認証情報を Workspace の環境変数（`AWS_ACCESS_KEY_ID` など、Sensitive 指定）に登録する必要があります。SSO の一時認証情報は数時間で切れるため、このハンズオンでは `Local` を使います。

## ここで押さえること

- ローカル state のまま複数人で作業すると、各自の state が食い違ったり、同時に `apply` して state が壊れたりする
- リモート state にすると、保存先の共有・ロック・バージョン履歴がまとめてそろう（AWS だけで完結させるなら S3 バックエンドも選べる）
- HCP Terraform の `Remote` 実行では、実行環境と認証情報がサーバー側にそろうため、誰が実行しても同じ結果になる

## 確認問題

1. 2 人が同時に `terraform apply` を実行すると、リモート state ではどうなるか？

<details>
<summary>答え</summary>

1. 先に始めた側が state をロックするため、後から実行した側はロック取得エラーで止まり、state は壊れない。

</details>

<details>
<summary>参考情報</summary>

- Collaborate using HCP Terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-hcp-terraform
- cloud ブロック: https://developer.hashicorp.com/terraform/cli/cloud/settings
- S3 バックエンド: https://developer.hashicorp.com/terraform/language/backend/s3

</details>
