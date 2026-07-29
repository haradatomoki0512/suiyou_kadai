# 掲示板Webアプリケーション 構築手順書

## 1. 前提パッケージのインストールと各種設定

Git、Docker、便利なエディタ（vim）、バックグラウンド作業用（screen）をインストールし、必要なプラグインの導入とサービス起動を行います。
 
```bash
sudo yum install -y docker
sudo systemctl start docker
```
dockerをインストールと起動をします
 
```bash
sudo usermod -a -G docker ec2-user
exit
```
ec2-userに権限を与えて反映させます
 
 
```bash
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v5.1.2/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
```
docker composeをインストールします

```bash
sudo yum install git -y
```
gitをインストールします


## 2. リポジトリのクローン

再ログイン後、作業ディレクトリに本リポジトリをクローンし、ディレクトリ内に移動します。

```bash
git clone https://github.com/haradatomoki0512/suiyou_kadai.git
cd suiyou_kadai
```

## 3. コンテナのビルドと起動

screenを起動し、Docker Composeを用いてNginx、PHP、MySQLのコンテナ環境のビルドと起動を分けて行います。

1. screenを起動します。
```bash
screen
```

2. コンテナを起動します。
```bash
docker compose up
```

```bash
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
```
docker compose upができない場合は上記を実行してください

> [!TIP]
> **screenの基本操作（別画面での作業）**
> 起動後は画面にログが流れ続けます。次のデータベース設定を行う場合は、以下の操作で新しいウィンドウを開いて作業してください。
> - 新しいウィンドウを開く: `Ctrl` + `a` の後に `c`
> - 次のウィンドウに移動: `Ctrl` + `a` の後に `n`
> - 前のウィンドウに移動: `Ctrl` + `a` の後に `p`

## 4. データベースの初期設定

（※ログが流れている画面とは別のscreenウィンドウで実行してください）
掲示板のデータを保存するテーブルを作成します。画像保存用のカラム（`image_filename`）も最初から含めて作成します。

1. 以下のコマンドで、起動中のMySQLコンテナに接続します。
```bash
docker compose exec mysql mysql example_db
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
