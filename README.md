# 掲示板Webアプリケーション 構築手順書

本手順書は、初期状態の Amazon Linux 2023 (EC2インスタンス) 上に、Dockerを用いて画像投稿可能なWeb掲示板を構築するためのCLI操作手順です。

## 1. 前提パッケージのインストールとDockerの起動

EC2インスタンスにSSHログインした直後の初期状態から、GitとDockerをインストールし、サービスを起動します。

```bash
sudo dnf update -y
sudo dnf install -y git docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user
```

> [!IMPORTANT]
> `ec2-user` へのDockerグループ追加を反映させるため、**ここで一度 `exit` でSSH接続を切断し、再度EC2にSSHログインし直してください。**

## 2. リポジトリのクローン

再ログイン後、作業ディレクトリに本リポジトリをクローンし、ディレクトリ内に移動します。

```bash
git clone [https://github.com/haradatomoki0512/suiyou_kadai.git](https://github.com/haradatomoki0512/suiyou_kadai.git)
cd suiyou_kadai
```

## 3. コンテナのビルドと起動

Docker Composeを用いて、Nginx、PHP、MySQLのコンテナ環境をビルドおよびバックグラウンドで起動します。

```bash
docker compose up -d --build
```
※起動完了後、`docker compose ps` で3つのコンテナが正常に稼働しているか確認してください。

## 4. データベースの初期設定

掲示板のデータを保存するテーブルを作成します。

1. 以下のコマンドで、起動中のMySQLコンテナに接続します。
```bash
docker compose exec mysql mysql -u root example_db
```

2. MySQLのプロンプト（`mysql>`）が表示されたら、以下のSQLを実行してテーブルを作成します。
```sql
CREATE TABLE `bbs_entries` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `body` TEXT NOT NULL,
    `image_filename` TEXT DEFAULT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

3. テーブルの作成が完了したら、MySQLから切断します。
```sql
exit
```

## 5. 動作確認

ブラウザを開き、EC2インスタンスのパブリックIPアドレスを使用して以下のURLにアクセスしてください。

```text
http://<EC2のパブリックIPアドレス>/bbsimagetest.php
```

テキストおよび5MB以下の画像が正常に投稿・表示されることが確認できれば構築は完了です。
