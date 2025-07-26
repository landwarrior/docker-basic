# SQL Server 2022 Docker 環境 (Vagrant + AlmaLinux9)

このプロジェクトは、VagrantでAlmaLinux9仮想マシン上でDocker Composeを使用してSQL Server 2022を簡単に起動・管理するための環境です。

## 📋 前提条件

- VirtualBox がインストールされていること
- Vagrant がインストールされていること
- ホストマシンに十分なメモリ（最低2GB推奨）があること

## 🚀 クイックスタート

### 1. Vagrant仮想マシンの起動

```bash
# プロジェクトルートディレクトリで実行
vagrant up
```

### 2. Vagrant仮想マシンに接続

```bash
# SSHで仮想マシンに接続
vagrant ssh
```

### 3. SQLServerディレクトリに移動

```bash
# 仮想マシン内で実行
cd /vagrant/SQLServer
```

### 4. コンテナの起動

```bash
# SQL Serverコンテナを起動
docker compose up -d
```

### 4-1. データベースの初期化（自動実行）

このプロジェクトでは、カスタムエントリーポイントスクリプト（`init-db.sh`）を使用して、SQL Serverコンテナ起動時に自動的にデータベースの初期化を行います。

#### 自動初期化の仕組み

1. **カスタムエントリーポイント**: `docker-compose.yml`で`entrypoint: ["/bin/bash", "/init-db.sh"]`を指定
2. **初期化スクリプト**: `init-db.sh`が以下の処理を実行：
   - SQL Serverの起動を30秒待機
   - `/docker-entrypoint-initdb.d/01-create-database.sql`を実行
   - SQL Serverプロセスを開始

#### 初期化スクリプトの内容

```bash
#!/bin/bash

# SQL Serverの起動を待つ
echo "Waiting for SQL Server to start..."
sleep 30

# 初期化SQLファイルを実行
echo "Running initialization scripts..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -i /docker-entrypoint-initdb.d/01-create-database.sql

echo "Database initialization completed."

# 元のエントリーポイントを実行
exec /opt/mssql/bin/sqlservr
```

#### 手動実行が必要な場合

自動初期化が失敗した場合や、追加のSQLを実行したい場合は、以下のコマンドで手動実行できます：

```bash
# 初期化SQLファイルを手動実行
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -i /docker-entrypoint-initdb.d/01-create-database.sql
```

### 5. コンテナの停止

```bash
# コンテナを停止
docker compose down

# データボリュームも削除する場合
docker compose down -v
```

### 6. ログの確認

```bash
# SQL Serverのログを確認
docker compose logs sqlserver

# リアルタイムでログを追跡
docker compose logs -f sqlserver
```

## 🔗 接続情報

### 仮想マシンのネットワーク情報

| 項目 | 値 |
|------|-----|
| ホスト名 | `docker-basic.local` |
| IPアドレス | `192.168.33.150` |
| SSH接続 | `vagrant ssh` |

### SQL Server接続パラメータ

| 項目 | 値 |
|------|-----|
| サーバー | `192.168.33.150,1433` |
| 認証方式 | SQL Server認証 |
| ユーザー名 | `sa` |
| パスワード | `YourStrong@Passw0rd` |
| データベース | `TestDB` |

### 接続例

#### SQL Server Management Studio (SSMS)
```
Server name: 192.168.33.150,1433
Authentication: SQL Server Authentication
Login: sa
Password: YourStrong@Passw0rd
```

#### Azure Data Studio
```
Server: 192.168.33.150,1433
Authentication Type: SQL Login
User name: sa
Password: YourStrong@Passw0rd
```

#### 接続文字列
```
Server=192.168.33.150,1433;Database=TestDB;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=true;
```

## 📊 データベース構造

### 作成されるテーブル

1. **Users** - ユーザー情報
   - Id (PK)
   - Name
   - Email (Unique)
   - Age
   - CreatedAt
   - UpdatedAt

2. **Products** - 商品情報
   - Id (PK)
   - Name
   - Description
   - Price
   - StockQuantity
   - CreatedAt

3. **Orders** - 注文情報
   - Id (PK)
   - UserId (FK to Users)
   - OrderDate
   - TotalAmount
   - Status

4. **OrderDetails** - 注文詳細
   - Id (PK)
   - OrderId (FK to Orders)
   - ProductId (FK to Products)
   - Quantity
   - UnitPrice

### 作成されるビュー

- **vw_UserOrders** - ユーザーと注文情報の結合ビュー

### 作成されるストアドプロシージャ

- **sp_GetUserOrders** - 指定ユーザーの注文履歴を取得

## 🛠️ 管理コマンド

### Vagrant仮想マシンの管理

```bash
# 仮想マシンを起動
vagrant up

# 仮想マシンを停止
vagrant halt

# 仮想マシンを再起動
vagrant reload

# 仮想マシンを削除
vagrant destroy

# 仮想マシンの状態確認
vagrant status
```

### コンテナの状態確認

```bash
# 仮想マシン内で実行
docker compose ps

# コンテナの詳細情報を確認
docker compose logs sqlserver
```

### データベースへの接続

```bash
# コンテナ内でSQL Serverに接続
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N

# データベース一覧の確認
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -Q "SELECT name FROM sys.databases"

# テーブル一覧の確認
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -Q "USE TestDB; SELECT table_name FROM information_schema.tables WHERE table_type = 'BASE TABLE'"
```

### バックアップの作成

```bash
# データベースのバックアップを作成
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -Q "BACKUP DATABASE TestDB TO DISK = '/backups/TestDB_$(date +%Y%m%d_%H%M%S).bak'"
```

### データの復元

```bash
# バックアップからデータを復元
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -Q "RESTORE DATABASE TestDB FROM DISK = '/backups/TestDB_20231201_120000.bak'"
```

## 🔧 設定のカスタマイズ

### パスワードの変更

`.env`ファイルを作成してパスワードを変更できます：

```env
MSSQL_SA_PASSWORD=YourNewStrongPassword
```

**注意**: パスワードを変更した場合は、`init-db.sh`と`docker-compose.yml`の`healthcheck`セクションも更新する必要があります。

### 自動初期化の無効化

自動初期化を無効にしたい場合は、`docker-compose.yml`の`entrypoint`行を削除またはコメントアウトしてください：

```yaml
# entrypoint: ["/bin/bash", "/init-db.sh"]  # この行をコメントアウト
```

### ポートの変更

`docker-compose.yml`の`ports`セクションを編集：

```yaml
ports:
  - "1434:1433"  # ホストポートを1434に変更
```

### データの永続化

データは`sqlserver_data`ボリュームに保存されます。完全に削除する場合：

```bash
docker compose down -v
docker volume rm sqlserver_sqlserver_data
```

## 📝 サンプルクエリ

### ユーザー一覧の取得

```sql
USE TestDB;
SELECT * FROM Users;
```

### 商品一覧の取得

```sql
USE TestDB;
SELECT * FROM Products;
```

### ユーザーの注文履歴

```sql
USE TestDB;
EXEC sp_GetUserOrders @UserId = 1;
```

### 売上集計

```sql
USE TestDB;
SELECT 
    p.Name,
    SUM(od.Quantity) as TotalSold,
    SUM(od.Quantity * od.UnitPrice) as TotalRevenue
FROM Products p
LEFT JOIN OrderDetails od ON p.Id = od.ProductId
GROUP BY p.Name
ORDER BY TotalRevenue DESC;
```

## 🔄 開発ワークフロー

### 1. 開発開始時

```bash
# ホストマシンで実行
vagrant up
vagrant ssh

# 仮想マシン内で実行
cd /vagrant/SQLServer
docker compose up -d
```

### 2. 開発終了時

```bash
# 仮想マシン内で実行
docker compose down

# 仮想マシンから抜ける
exit

# ホストマシンで実行（必要に応じて）
vagrant halt
```

### 3. コード変更時の反映

```bash
# 仮想マシン内で実行
cd /vagrant/SQLServer
docker compose down
docker compose up -d --force-recreate
```

## ⚠️ 注意事項

1. **セキュリティ**: 本番環境では必ず強力なパスワードに変更してください
2. **パフォーマンス**: 開発・テスト用途に最適化されています
3. **ライセンス**: SQL Server Developer Editionを使用しています（無料）
4. **データ永続化**: コンテナを削除してもデータは保持されます
5. **ネットワーク**: 仮想マシンのIPアドレス（192.168.33.150）でアクセスしてください
6. **リソース**: 仮想マシンには最低2GBのメモリが割り当てられています

## 🐛 トラブルシューティング

### 仮想マシンが起動しない場合

```bash
# 仮想マシンの状態を確認
vagrant status

# ログを確認
vagrant up --debug

# 仮想マシンを再作成
vagrant destroy
vagrant up
```

### コンテナが起動しない場合

```bash
# 仮想マシン内でログを確認
docker compose logs sqlserver

# コンテナを再作成
docker compose down
docker compose up -d --force-recreate
```

### データベースが作成されない場合

```bash
# 初期化スクリプトのログを確認
docker compose logs sqlserver | grep -i "initialization\|database"

# 手動でデータベースを初期化
docker compose exec sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -i /docker-entrypoint-initdb.d/01-create-database.sql

# 初期化スクリプトの権限を確認
docker compose exec sqlserver ls -la /init-db.sh
```

### 接続できない場合

1. 仮想マシンが起動しているか確認
2. ポート1433が他のアプリケーションで使用されていないか確認
3. ファイアウォールの設定を確認
4. SQL Serverが完全に起動するまで数分待機

### パスワードエラーの場合

```bash
# コンテナを停止して再起動
docker compose down
docker compose up -d
```

### ファイル同期の問題

```bash
# 仮想マシンを再起動
vagrant reload

# または仮想マシンを再作成
vagrant destroy
vagrant up
```

## 📚 参考リンク

- [SQL Server Docker Hub](https://hub.docker.com/_/microsoft-mssql-server)
- [SQL Server ドキュメント](https://docs.microsoft.com/ja-jp/sql/sql-server/)
- [Docker Compose ドキュメント](https://docs.docker.com/compose/)
- [Vagrant ドキュメント](https://www.vagrantup.com/docs)
- [AlmaLinux ドキュメント](https://almalinux.org/) 
