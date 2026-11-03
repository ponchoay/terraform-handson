# 第 4 章 モジュールで VPC を作る

## 要約

Terraform Registry の公開モジュール `terraform-aws-modules/vpc/aws` を呼び出して専用の VPC とサブネットを作り、EC2 インスタンスをそのプライベートサブネットに移します。モジュールは「変数を受け取り、リソースを作り、出力を返す」再利用可能な部品で、呼び出し側は `module.<名前>.<出力名>` で結果を参照します（約 25 分）。

## この章のゴール

- `module` ブロックで Registry のモジュールを呼び出せる
- モジュールの出力を他のリソースから参照できる
- モジュールを追加・変更したら `terraform init` が必要な理由を説明できる

## 手順

1. `main.tf` の `provider "aws"` の下に VPC モジュールを追加する（NAT Gateway は時間課金のため作らない）

   ```hcl
   module "vpc" {
     source  = "terraform-aws-modules/vpc/aws"
     version = "5.19.0"

     name = "example-vpc"
     cidr = "10.0.0.0/16"

     azs             = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
     private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
     public_subnets  = ["10.0.101.0/24"]

     enable_dns_hostnames = true
   }
   ```

2. `aws_instance.app_server` に、モジュールが作るサブネットとセキュリティグループを指定する

   ```hcl
   resource "aws_instance" "app_server" {
     ami                    = data.aws_ami.ubuntu.id
     instance_type          = var.instance_type
     vpc_security_group_ids = [module.vpc.default_security_group_id]
     subnet_id              = module.vpc.private_subnets[0]

     tags = {
       Name = var.instance_name
       Env  = "handson"
     }
   }
   ```

3. モジュールをダウンロードする（`.terraform/modules/vpc/` にソースが展開される）

   ```shell
   terraform init
   ```

4. 計画を確認する（VPC・サブネット・ルートテーブルなど約 20 個の `+` と、`subnet_id` の変更による `aws_instance.app_server` の `-/+` が出る）

   ```shell
   terraform plan
   ```

5. 適用する（`yes` と入力。2〜3 分かかる）

   ```shell
   terraform apply
   ```

6. 管理対象のリソースを一覧する（`module.vpc.` で始まる行がモジュール内のリソース）

   ```shell
   terraform state list
   ```

7. VPC コンソールで `example-vpc` が作られ、EC2 コンソールでインスタンスがそのサブネットにあることを確認する

インスタンスはパブリック IP を持たないプライベートサブネットに移ったため、出力 `instance_public_ip` は空文字になります。

## ここで押さえること

- `source` はモジュールの取得元で、Registry（`<namespace>/<name>/<provider>`）、ローカルパス（`./modules/web`）、Git リポジトリなどを指定できる
- Registry のモジュールは `version` で固定する（固定しないと、別の環境での初回 `init` や `init -upgrade` で新しい版が入り、環境ごとに意図しない差分が出る）
- `module.vpc.private_subnets` のように参照できるのは、モジュールが `output` で公開している値だけ（一覧は Registry のモジュールページの「Outputs」タブ）
- 自分で作るモジュールも構造は同じで、ディレクトリに `variables.tf`・`main.tf`・`outputs.tf` を置き、`source = "./modules/<名前>"` で呼び出す

## 確認問題

1. `version = "5.19.0"` を `"5.20.0"` に変えて `plan` だけ実行するとどうなるか？
2. 作成されたパブリックサブネットの ID を出力するには `outputs.tf` に何を書けばよいか？

<details>
<summary>答え</summary>

1. ダウンロード済みのモジュールのバージョンと合わないため、`terraform init` を実行するよう求めるエラーになる（`init -upgrade` で更新できる）。
2. `output "public_subnet_ids" { value = module.vpc.public_subnets }` のように、モジュールの出力 `public_subnets` を参照する。

</details>

<details>
<summary>参考情報</summary>

- Manage infrastructure（モジュール）: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-manage
- Fundamentals - Modules: https://developer.hashicorp.com/terraform/tutorials/modules
- terraform-aws-modules/vpc/aws: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/5.19.0

</details>
