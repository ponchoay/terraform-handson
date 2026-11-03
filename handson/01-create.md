# 第 1 章 インフラの作成

## 要約

2 つの `.tf` ファイルに EC2 インスタンス 1 台を定義し、`terraform init` → `plan` → `apply` で作成します。Terraform は「コードに書いた状態」と「state に記録された現在の状態」の差分だけを実行する、という仕組みをこの章でつかみます（約 25 分）。

## この章のゴール

- IaC（Infrastructure as Code）とは何かを説明できる
- `init` / `fmt` / `validate` / `plan` / `apply` の役割を説明できる
- `terraform.tfstate` が何を記録しているかを説明できる

## IaC と Terraform の考え方

IaC はインフラの構成をコンソール操作ではなくコードで定義し、バージョン管理・レビュー・再現を可能にする手法です。「あるべき姿」を宣言的に書くと、Terraform が現在の状態との差分を計算して API を呼び出します。基本の流れは次の 3 段階です。

| 段階 | コマンド | すること |
|---|---|---|
| Write | （エディタ） | `.tf` ファイルにあるべき姿を書く |
| Plan | `terraform plan` | 現在の状態との差分（実行計画）を表示する |
| Apply | `terraform apply` | 実行計画のとおりに作成・変更・削除する |

## 手順

1. 作業ディレクトリを作って移動する

   ```shell
   mkdir learn-terraform-aws
   cd learn-terraform-aws
   ```

2. `terraform.tf` を作成する（Terraform 本体と provider のバージョン制約）

   ```hcl
   terraform {
     required_providers {
       aws = {
         source  = "hashicorp/aws"
         version = "~> 5.92"
       }
     }

     required_version = ">= 1.2"
   }
   ```

3. `main.tf` を作成する（provider・最新 Ubuntu AMI の検索・EC2 インスタンス）

   ```hcl
   provider "aws" {
     region = "ap-northeast-1"
   }

   data "aws_ami" "ubuntu" {
     most_recent = true

     filter {
       name   = "name"
       values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
     }

     owners = ["099720109477"] # Canonical
   }

   resource "aws_instance" "app_server" {
     ami           = data.aws_ami.ubuntu.id
     instance_type = "t3.micro"

     tags = {
       Name = "learn-terraform"
     }
   }
   ```

4. 書式を整える（変更したファイル名が表示される。何も出なければ整形済み）

   ```shell
   terraform fmt
   ```

5. 初期化する（`.terraform/` に AWS provider がダウンロードされ、`.terraform.lock.hcl` が作られる）

   ```shell
   terraform init
   ```

6. 構文を検証する（`Success! The configuration is valid.` が出れば OK）

   ```shell
   terraform validate
   ```

7. 実行計画を確認する（`Plan: 1 to add, 0 to change, 0 to destroy.` が出る）

   ```shell
   terraform plan
   ```

8. 適用する（計画が表示されたら `yes` と入力。完了まで 1 分程度）

   ```shell
   terraform apply
   ```

9. AWS コンソールの EC2 画面で、Name が `learn-terraform` のインスタンスが起動していることを確認する
10. Terraform が管理しているリソースを一覧する

    ```shell
    terraform state list
    ```

11. state に記録された属性の詳細を表示する（`public_ip` や `instance_state` が見える）

    ```shell
    terraform show
    ```

`apply` で `No default VPC for this user` が出る場合、そのリージョンにデフォルト VPC がありません。`aws ec2 create-default-vpc` でデフォルト VPC を作り直してから、もう一度 `terraform apply` を実行してください（VPC 自体は無料で、Terraform の管理外なので第 6 章の `destroy` では消えません）。

## ここで押さえること

- `resource "aws_instance" "app_server"` の `aws_instance` はリソースの種類、`app_server` はコード内での名前で、`aws_instance.app_server` で参照する
- `data` ブロックは既存の情報を読むだけで、何も作らない
- `terraform.tfstate` は実際に作られたリソースの ID や属性の記録で、次回以降の `plan` は、state をもとに実環境を読み直した結果とコードを比べて差分を出す（詳しくは第 5 章）
- `terraform.tfstate` には機密値が平文で入ることがあるため Git にコミットしない（`.gitignore` に `*.tfstate*` と `.terraform/` を入れる）。`.terraform.lock.hcl` はコミットする

## 確認問題

1. `terraform init` を省略して `plan` するとどうなるか？
2. `plan` と `apply` の違いは何か？
3. `terraform.tfstate` を削除してから `plan` するとどうなるか？

<details>
<summary>答え</summary>

1. provider がダウンロードされていないため、`init` を実行するよう求めるエラーになる。
2. `plan` は差分を表示するだけで何も変更しない。`apply` は計画を作ったうえで、承認後に実際に変更する。
3. Terraform は既存インスタンスを知らない状態になるため、もう 1 台作成する計画（`1 to add`）が出る。実際のインスタンスは残ったままになる。

</details>

<details>
<summary>参考情報</summary>

- What is Infrastructure as Code with Terraform?: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/infrastructure-as-code
- Create infrastructure: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create
- aws_instance リソース: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance

</details>
