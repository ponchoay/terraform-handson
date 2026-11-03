# 第 0 章 環境の準備

## 要約

Terraform CLI と AWS CLI を Homebrew で入れ、AWS の認証情報を設定します。`terraform -version` と `aws sts get-caller-identity` の両方が成功すれば準備完了です（約 20 分）。

## この章のゴール

- `terraform` コマンドが使える
- Terraform から AWS を操作するための認証情報が設定されている

## 手順

### Terraform のインストール

1. HashiCorp の Homebrew tap を追加する

   ```shell
   brew tap hashicorp/tap
   ```

2. Terraform をインストールする

   ```shell
   brew install hashicorp/tap/terraform
   ```

3. バージョンが表示されることを確認する

   ```shell
   terraform -version
   ```

4. （任意）タブ補完を有効にし、シェルを再起動する

   ```shell
   terraform -install-autocomplete
   ```

### AWS CLI のインストールと認証

Terraform の AWS provider は AWS CLI と同じ認証情報を読みます。会社のアカウントで IAM Identity Center（SSO）を使っている場合は方法 A、個人アカウントで IAM ユーザーのアクセスキーを使う場合は方法 B を選んでください。

1. AWS CLI をインストールする

   ```shell
   brew install awscli
   ```

2. 認証情報を設定する
   - 方法 A（SSO）: `aws configure sso` を実行し、プロファイル名に `handson` と入力する
   - 方法 B（アクセスキー）: `aws configure --profile handson` を実行し、アクセスキー・シークレットキー・リージョン `ap-northeast-1` を入力する
3. このターミナルで使うプロファイルを指定する

   ```shell
   export AWS_PROFILE=handson
   ```

4. 認証できていることを確認する（アカウント ID が表示されれば成功）

   ```shell
   aws sts get-caller-identity
   ```

SSO の場合はセッションが数時間で切れます。後の章で `ExpiredToken` などのエラーが出たら `aws sso login` を実行し直してください。

### エディタの準備（任意）

VS Code を使う場合は拡張機能「HashiCorp Terraform」を入れると、補完と構文チェックが使えるようになります。

## 確認問題

1. Terraform は AWS の認証情報をどこから読むか？

<details>
<summary>答え</summary>

1. AWS CLI と同じ場所（環境変数 `AWS_PROFILE` / `AWS_ACCESS_KEY_ID` など、`~/.aws/config`・`~/.aws/credentials`）から読む。

</details>

<details>
<summary>参考情報</summary>

- Install Terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
- AWS provider の認証方法: https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration

</details>
