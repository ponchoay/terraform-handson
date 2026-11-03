# 第 2 章 インフラの変更

## 要約

第 1 章のインスタンスに対し、タグの変更（その場で更新）と AMI の変更（作り直し）を行い、`plan` の記号 `~` と `-/+` の違いを読み取れるようにします。変更の種類によってはリソースが削除・再作成されるため、`apply` の前に必ず `plan` を読む習慣をつけます（約 15 分）。

## この章のゴール

- `plan` 出力の記号（`+` / `~` / `-` / `-/+`）を読み分けられる
- どの変更がリソースの再作成を伴うかを `plan` から判断できる

## plan 出力の記号

| 記号 | 意味 | 例 |
|---|---|---|
| `+` | 作成 | 新しいリソースを追加した |
| `~` | その場で更新（in-place） | タグを変えた |
| `-` | 削除 | リソースのブロックを消した |
| `-/+` | 削除してから再作成（replace） | AMI を変えた |

## 手順

### タグを変更する（in-place 更新）

1. `main.tf` の `aws_instance.app_server` の `tags` に `Env = "handson"` を追加する

   ```hcl
     tags = {
       Name = "learn-terraform"
       Env  = "handson"
     }
   ```

2. 計画を確認する（`~ update in-place` と `Plan: 0 to add, 1 to change, 0 to destroy.` が出る）

   ```shell
   terraform plan
   ```

3. 適用する（`yes` と入力）

   ```shell
   terraform apply
   ```

### AMI を変更する（再作成）

4. `data "aws_ami" "ubuntu"` の `values` を Ubuntu 22.04 に変える

   ```hcl
       values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
   ```

5. 計画を確認する（`-/+ resource "aws_instance" "app_server"`、`ami` の行に `# forces replacement`、`Plan: 1 to add, 0 to change, 1 to destroy.` が出る）

   ```shell
   terraform plan
   ```

6. 適用する（`yes` と入力。旧インスタンスの削除と新インスタンスの作成で 1〜2 分かかる）

   ```shell
   terraform apply
   ```

7. EC2 コンソールで、インスタンス ID が変わったことを確認する
8. `values` を Ubuntu 24.04（`ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*`）に戻し、`terraform apply` で元に戻す（以降の章は 24.04 前提）

## ここで押さえること

- 再作成になるかどうかは属性ごとに provider が決めており、`plan` の `# forces replacement` で判別できる
- 再作成ではインスタンス ID・IP アドレス・ディスクの中身が変わるため、本番では影響を確認してから適用する
- `terraform plan -out=tfplan` で計画を保存し、`terraform apply tfplan` とすると、確認した計画どおりに適用できる

## 確認問題

1. `instance_type` を `t3.micro` から `t3.small` に変えると、`plan` の記号はどれになるか？（実際に `plan` だけ実行して確かめる。`apply` はしない）
2. `plan` を確認してから `apply` までの間に誰かがコードを変えた場合、確認した内容と違う変更が適用されないようにするにはどうするか？

<details>
<summary>答え</summary>

1. `~`（in-place 更新）。EC2 はインスタンスを停止・起動してタイプを変えるため、ID は変わらない。
2. `terraform plan -out=tfplan` で計画を保存し、`terraform apply tfplan` で保存した計画を適用する。

</details>

<details>
<summary>参考情報</summary>

- Manage infrastructure: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-manage
- plan コマンド: https://developer.hashicorp.com/terraform/cli/commands/plan

</details>
