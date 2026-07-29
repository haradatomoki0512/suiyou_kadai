# 掲示板Webアプリケーション 構築手順書

本手順書は、初期状態の Amazon Linux 2023 (EC2インスタンス) 上に、Dockerを用いて画像投稿可能なWeb掲示板を構築するためのCLI操作手順です。

## 1. 前提パッケージのインストールと各種設定

Git、Docker、便利なエディタ（vim）、バックグラウンド作業用（screen）をインストールし、必要なプラグインの導入とサービス起動を行います。

```bash
# パッケージのインストール
sudo dnf update -y
sudo dnf install -y git docker screen vim

# Dockerの起動と権限設定
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Docker Composeのインストール
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL [https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64](https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64) -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Buildxのインストール（ビルド時のエラー防止対策）
mkdir -p ~/.docker/cli-plugins
ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
BUILDX_URL=$(curl -s [https://api.github.com/repos/docker/buildx/releases/latest](https://api.github.com/repos/docker/buildx/releases/latest) | grep "browser_download_url.*linux-$ARCH" | cut -d '"' -f 4)
curl -L $BUILDX_URL -o ~/.docker/cli-plugins/docker-buildx
chmod +x ~/.docker/cli-plugins/docker-buildx
```

> [!IMPORTANT]
> `ec2-user` へのDockerグループ追加を反映させるため、**ここで一度 `exit` でSSH接続を切断し、再度EC2にログインし直してください。**

> [!TIP]
> **エディタ・ツールのカスタマイズ（任意）**
> - **vim:** `vim ~/.vimrc` で設定ファイルを作成し、授業で習ったおすすめ設定を記述できます。
> - **screen:** `vim ~/.screenrc` で設定ファイルを作成し、ステータスバーの表示などをカスタマイズできます。

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

2. コンテナをビルドします。
```bash
docker compose build
```

3. コンテナを起動します。
```bash
docker compose up
```

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
