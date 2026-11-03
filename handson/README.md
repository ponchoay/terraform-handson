# Terraform ハンズオン（AWS 編）

## 要約

HashiCorp 公式チュートリアル「Get Started - AWS」と Fundamentals（State・Modules）をもとに、EC2 インスタンス 1 台を Terraform で作成・変更・削除するまでを日本語で順に体験する教材です。必須の第 0〜6 章と任意の第 7 章の全 8 章で、必須部分は合計約 2 時間 20 分かかります。作成したリソースには料金がかかるため、作業を中断するときは第 6 章の `terraform destroy` を実行してください。

## 章の一覧

| 章 | ファイル | 学ぶこと | 目安時間 |
|---|---|---|---|
| 0 | [00-setup.md](00-setup.md) | Terraform・AWS CLI のインストールと AWS 認証 | 約 20 分 |
| 1 | [01-create.md](01-create.md) | IaC の考え方、`init` / `plan` / `apply` で EC2 を作成 | 約 25 分 |
| 2 | [02-change.md](02-change.md) | 設定の変更、in-place 更新と再作成の違い | 約 15 分 |
| 3 | [03-variables-outputs.md](03-variables-outputs.md) | 入力変数と出力値 | 約 20 分 |
| 4 | [04-modules.md](04-modules.md) | Registry のモジュールで VPC を作る | 約 25 分 |
| 5 | [05-state.md](05-state.md) | state の確認、ドリフト検出、`moved` によるリネーム | 約 25 分 |
| 6 | [06-destroy.md](06-destroy.md) | 削除計画の確認と全削除 | 約 10 分 |
| 7（任意） | [07-hcp-terraform.md](07-hcp-terraform.md) | HCP Terraform に state を置いてチームで使う | 約 30 分 |

## 進め方

1. 第 0 章で環境を整える
2. 第 1 章から順に進める（各章は前の章のコードを引き継ぐ）
3. 各章末の「確認問題」に答えられるか確かめる
4. その日の作業を終えるときは第 6 章の手順でリソースを全削除する

作業ディレクトリは全章で共通の `learn-terraform-aws/` を使います。この `handson/` フォルダとは別の場所に作ってください。

## 料金と前提

- 使うリソースは EC2（`t3.micro`）・EBS（8 GB）・VPC（NAT Gateway なし）だけで、無料利用枠の対象外でも 1 時間あたり約 3 円です
- AWS アカウントと、EC2・VPC を作成できる権限が必要です
- リージョンは東京（`ap-northeast-1`）を使います（公式チュートリアルは `us-west-2`）

## 公式チュートリアルとの違い

| 項目 | 公式 | この教材 | 変えた理由 |
|---|---|---|---|
| リージョン | `us-west-2` | `ap-northeast-1` | 日本から使う場合に一般的なため |
| インスタンスタイプ | `t2.micro` | `t3.micro` | 2025 年 7 月以降に作られたアカウントの無料利用枠は `t3.micro` が対象のため |
| state の操作 | Get Started には含まれない | 第 5 章で扱う | 実務で最初につまずきやすいため Fundamentals の State から取り入れた |

<details>
<summary>参考情報</summary>

- 公式チュートリアル一覧: https://developer.hashicorp.com/terraform/tutorials
- Get Started - AWS: https://developer.hashicorp.com/terraform/tutorials/aws-get-started
- Fundamentals - State: https://developer.hashicorp.com/terraform/tutorials/state
- Fundamentals - Modules: https://developer.hashicorp.com/terraform/tutorials/modules
- AWS provider ドキュメント: https://registry.terraform.io/providers/hashicorp/aws/latest/docs

</details>
