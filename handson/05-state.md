# 第 5 章 state の扱い

## 要約

Terraform の state を調べるコマンド、コンソールなど Terraform 外での変更（ドリフト）の検出と修正、`moved` ブロックによるリソース名の変更を体験します。state は Terraform が「何を管理しているか」を知る唯一の記録なので、直接編集せずコマンドやブロックで操作します（約 25 分）。

## この章のゴール

- `state list` / `state show` で管理中のリソースを調べられる
- ドリフトを `plan -refresh-only` で検出し、コードの状態に戻せる
- `moved` ブロックで、リソースを作り直さずにコード上の名前を変えられる

## 手順

### state を調べる

1. 管理中のリソースを一覧する

   ```shell
   terraform state list
   ```

2. インスタンス 1 つの属性を表示する

   ```shell
   terraform state show aws_instance.app_server
   ```

### ドリフトを検出して直す

3. Terraform を使わずに AWS CLI で Name タグを書き換える（手作業での変更を再現する）

   ```shell
   aws ec2 create-tags --resources $(terraform output -raw instance_id) --tags Key=Name,Value=manually-changed
   ```

4. 実際の状態と state の差分だけを確認する（`Objects have changed outside of Terraform` と、`Name` が `manually-changed` になった差分が出る）

   ```shell
   terraform plan -refresh-only
   ```

5. コードとの差分を確認する（`Name` を `learn-terraform-tfvars` に戻す `~` の差分が出る）

   ```shell
   terraform plan
   ```

6. 適用してコードの状態に戻す（`yes` と入力）

   ```shell
   terraform apply
   ```

### moved でリソース名を変える

7. `main.tf` の `resource "aws_instance" "app_server"` を `resource "aws_instance" "web"` に書き換える
8. `outputs.tf` の `aws_instance.app_server` 3 か所を `aws_instance.web` に書き換える
9. この段階で計画を確認する（`app_server` の削除と `web` の作成、`1 to add, 0 to change, 1 to destroy` が出る。`apply` はしない）

   ```shell
   terraform plan
   ```

10. `main.tf` の末尾に `moved` ブロックを追加する

    ```hcl
    moved {
      from = aws_instance.app_server
      to   = aws_instance.web
    }
    ```

11. もう一度計画を確認する（`aws_instance.app_server has moved to aws_instance.web` と `0 to add, 0 to change, 0 to destroy` が出る）

    ```shell
    terraform plan
    ```

12. 適用して state 上の名前を変える（`yes` と入力）

    ```shell
    terraform apply
    ```

13. `terraform state list` で `aws_instance.web` に変わったことを確認する

## ここで押さえること

- `plan` は毎回まず実環境を読み直し（refresh）、その結果とコードを比べる。`-refresh-only` は実環境と state の差分だけを見る
- ドリフトを直す方法は 2 つある。コードの状態に戻すなら `apply`、手作業の変更を正とするならコードを書き換えてから `apply`
- `moved` ブロックはリファクタリングの履歴としてコードに残り、他の環境でも同じ移動が適用される（同じことを手動で行う `terraform state mv` もある）
- 既存のリソースを Terraform 管理に取り込むときは `import` ブロック、管理から外すだけで実物は残すときは `removed` ブロックを使う
- 複数人で作業するときは state をローカルではなく S3 や HCP Terraform などのリモートに置き、同時実行をロックする（第 7 章）

## 確認問題

1. `terraform.tfstate` をエディタで直接編集してはいけない理由は何か？
2. 手順 9 の状態で `apply` していたら、何が起きていたか？

<details>
<summary>答え</summary>

1. 形式を壊すと Terraform が実環境を正しく追跡できなくなり、リソースの重複作成や意図しない削除につながるため。操作は `state` サブコマンドや `moved` / `import` / `removed` ブロックで行う。
2. 既存のインスタンスが削除され、同じ設定の新しいインスタンスが別の ID で作られていた。

</details>

<details>
<summary>参考情報</summary>

- Fundamentals - State: https://developer.hashicorp.com/terraform/tutorials/state
- Manage resource drift: https://developer.hashicorp.com/terraform/tutorials/state/resource-drift
- Use refactoring to move resources（moved ブロック）: https://developer.hashicorp.com/terraform/language/modules/develop/refactoring

</details>
