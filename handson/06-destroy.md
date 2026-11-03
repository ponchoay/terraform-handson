# 第 6 章 インフラの削除

## 要約

`terraform destroy` で、このハンズオンで作った EC2 インスタンスと VPC 一式を削除します。課金を止めるため、ハンズオンを中断・終了するときは毎回この章を実行してください（約 10 分）。

## この章のゴール

- 削除される内容を事前に確認してから全削除できる
- 一部のリソースだけを削除する方法を説明できる

## 手順

1. 削除計画だけを確認する（作成済みの全リソースが `-` で表示され、最終行に `Plan: 0 to add, 0 to change, N to destroy.`（N は作成済みのリソース数）が出る）

   ```shell
   terraform plan -destroy
   ```

2. 削除する（`yes` と入力。2〜3 分かかる）

   ```shell
   terraform destroy
   ```

3. 管理中のリソースが残っていないことを確認する（何も表示されなければ OK）

   ```shell
   terraform state list
   ```

4. EC2 コンソールでインスタンスが `終了済み`、VPC コンソールで `example-vpc` が消えていることを確認する

再開するときは、同じディレクトリで `terraform apply` を実行すれば直前の章の状態が作り直されます。

## ここで押さえること

- `terraform destroy` は `terraform apply -destroy` と同じで、state にある全リソースを依存関係の逆順（インスタンス → サブネット → VPC）に削除する
- 一部だけ削除したいときは、コードから該当ブロックを消して `apply` する（`-target` オプションでも可能だが、コードと state がずれる原因になるため緊急時だけに使う）
- 本番環境のリソースには `lifecycle { prevent_destroy = true }` を付けると、誤って削除する計画をエラーで止められる

## 確認問題

1. `main.tf` から `module "vpc"` ブロックだけを削除して `plan` すると、どうなるか？

<details>
<summary>答え</summary>

1. `aws_instance.web` が `module.vpc` の出力を参照しているため、参照先が見つからないエラーになる。VPC を消すには、インスタンス側の参照も外す必要がある。

</details>

<details>
<summary>参考情報</summary>

- Destroy infrastructure: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-destroy
- destroy コマンド: https://developer.hashicorp.com/terraform/cli/commands/destroy

</details>
