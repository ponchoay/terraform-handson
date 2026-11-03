# 第 3 章 入力変数と出力値

## 要約

ハードコードしていたインスタンス名とタイプを入力変数（`variable`）に切り出し、インスタンス ID や IP アドレスを出力値（`output`）として取り出せるようにします。変数の渡し方は 4 通りあり、優先順位を知っておくと「どの値が使われたか」で迷わなくなります（約 20 分）。

## この章のゴール

- `variable` を宣言して `var.<名前>` で参照できる
- 変数の値を渡す 4 つの方法と優先順位を説明できる
- `output` を宣言して `terraform output` で値を取り出せる

## 手順

### 入力変数を追加する

1. `variables.tf` を作成する

   ```hcl
   variable "instance_name" {
     description = "EC2 インスタンスの Name タグ"
     type        = string
     default     = "learn-terraform"
   }

   variable "instance_type" {
     description = "EC2 インスタンスタイプ"
     type        = string
     default     = "t3.micro"

     validation {
       condition     = startswith(var.instance_type, "t3.")
       error_message = "ハンズオンでは t3 系のインスタンスタイプだけを使います。"
     }
   }
   ```

2. `main.tf` の `aws_instance.app_server` を変数参照に書き換える

   ```hcl
   resource "aws_instance" "app_server" {
     ami           = data.aws_ami.ubuntu.id
     instance_type = var.instance_type

     tags = {
       Name = var.instance_name
       Env  = "handson"
     }
   }
   ```

3. 計画を確認する（値はデフォルトと同じなので `No changes.` が出る）

   ```shell
   terraform plan
   ```

4. コマンドラインで変数を渡して計画だけ確認する（`instance_type` が `t3.small` になる `~` の差分が出る。`apply` はしない）

   ```shell
   terraform plan -var instance_type=t3.small
   ```

5. validation を確かめる（`ハンズオンでは t3 系の...` のエラーが出る）

   ```shell
   terraform plan -var instance_type=m5.large
   ```

6. `terraform.tfvars` を作成し、名前を変える

   ```hcl
   instance_name = "learn-terraform-tfvars"
   ```

7. 適用する（Name タグが `learn-terraform-tfvars` に変わる `~` の差分が出るので `yes`）

   ```shell
   terraform apply
   ```

### 出力値を追加する

8. `outputs.tf` を作成する

   ```hcl
   output "instance_id" {
     description = "EC2 インスタンスの ID"
     value       = aws_instance.app_server.id
   }

   output "instance_public_ip" {
     description = "EC2 インスタンスのパブリック IP"
     value       = aws_instance.app_server.public_ip
   }

   output "instance_hostname" {
     description = "EC2 インスタンスのプライベート DNS 名"
     value       = aws_instance.app_server.private_dns
   }
   ```

9. 適用する（リソースの変更はなく、`Outputs:` に 3 つの値が表示される）

   ```shell
   terraform apply
   ```

10. 出力値を一覧する

    ```shell
    terraform output
    ```

11. 1 つの値を引用符なしで取り出す（シェルスクリプトで使う形）

    ```shell
    terraform output -raw instance_id
    ```

## 変数の渡し方と優先順位

下の行ほど優先され、同じ変数に複数の方法で値を渡すと下の行の値が使われます。

| 優先順位 | 方法 | 例 |
|---|---|---|
| 1（最低） | `default` | `variables.tf` の `default = "t3.micro"` |
| 2 | 環境変数 `TF_VAR_<名前>` | `export TF_VAR_instance_type=t3.small` |
| 3 | `terraform.tfvars`、`*.auto.tfvars` | 自動で読み込まれる（`*.auto.tfvars` が後） |
| 4（最高） | `-var` / `-var-file` | `terraform plan -var instance_type=t3.small` |

`default` がなく、どの方法でも値が渡されない変数は、`plan` 実行時に対話入力を求められます。

## 確認問題

1. `terraform.tfvars` に `instance_name = "a"`、環境変数に `TF_VAR_instance_name=b` を設定して `plan` すると、どちらが使われるか？
2. パスワードのような機密値を出力するとき、画面に表示させないにはどうするか？

<details>
<summary>答え</summary>

1. `a`。`terraform.tfvars` のほうが環境変数より優先される。
2. `output` に `sensitive = true` を付ける。`terraform output` の一覧では `<sensitive>` と表示される（state には平文で残る点は変わらない）。

</details>

<details>
<summary>参考情報</summary>

- Manage infrastructure（変数・出力）: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-manage
- Input variables: https://developer.hashicorp.com/terraform/language/values/variables
- Output values: https://developer.hashicorp.com/terraform/language/values/outputs

</details>
