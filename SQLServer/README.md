# SQL Server 2022 Docker Swarm 環境 (Vagrant + AlmaLinux9)

このプロジェクトは、VagrantでAlmaLinux9仮想マシン上でDocker Swarmを使用してSQL Server 2022を簡単に起動・管理するための環境です。

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

### 4. Docker Swarmスタックのデプロイ

```bash
# SQL Serverスタックをデプロイ
./deploy-stack.sh
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
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -i /docker-entrypoint-initdb.d/01-create-database.sql
```

### 5. スタックの停止

```bash
# スタックを削除
docker stack rm sqlserver-stack

# データボリュームも削除する場合
docker volume rm sqlserver_sqlserver_data
```

### 6. ログの確認

```bash
# SQL Serverのログを確認
docker service logs sqlserver-stack_sqlserver

# リアルタイムでログを追跡
docker service logs -f sqlserver-stack_sqlserver
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

このプロジェクトでは、ECサイトを想定したサンプルデータベース「TestDB」を作成します。

### データベース概要

- **データベース名**: TestDB
- **文字エンコーディング**: Unicode (NVARCHAR使用)
- **日時型**: DATETIME2 (高精度)
- **数値型**: DECIMAL(10,2) (通貨計算用)

### テーブル関係図

```
Users (1) ←→ (N) Orders (1) ←→ (N) OrderDetails (N) ←→ (1) Products
```

### 作成されるテーブル

1. **Users** - ユーザー情報
   - `Id` (INT, PK, IDENTITY(1,1)) - ユーザーID
   - `Name` (NVARCHAR(100), NOT NULL) - ユーザー名
   - `Email` (NVARCHAR(255), UNIQUE, NOT NULL) - メールアドレス
   - `Age` (INT) - 年齢
   - `CreatedAt` (DATETIME2, DEFAULT GETDATE()) - 作成日時
   - `UpdatedAt` (DATETIME2, DEFAULT GETDATE()) - 更新日時

2. **Products** - 商品情報
   - `Id` (INT, PK, IDENTITY(1,1)) - 商品ID
   - `Name` (NVARCHAR(200), NOT NULL) - 商品名
   - `Description` (NVARCHAR(500)) - 商品説明
   - `Price` (DECIMAL(10,2), NOT NULL) - 価格
   - `StockQuantity` (INT, DEFAULT 0) - 在庫数量
   - `CreatedAt` (DATETIME2, DEFAULT GETDATE()) - 作成日時

3. **Orders** - 注文情報
   - `Id` (INT, PK, IDENTITY(1,1)) - 注文ID
   - `UserId` (INT, NOT NULL, FK to Users) - ユーザーID
   - `OrderDate` (DATETIME2, DEFAULT GETDATE()) - 注文日時
   - `TotalAmount` (DECIMAL(10,2), NOT NULL) - 合計金額
   - `Status` (NVARCHAR(50), DEFAULT 'Pending') - 注文ステータス

4. **OrderDetails** - 注文詳細
   - `Id` (INT, PK, IDENTITY(1,1)) - 注文詳細ID
   - `OrderId` (INT, NOT NULL, FK to Orders) - 注文ID
   - `ProductId` (INT, NOT NULL, FK to Products) - 商品ID
   - `Quantity` (INT, NOT NULL) - 数量
   - `UnitPrice` (DECIMAL(10,2), NOT NULL) - 単価

5. **AzureServices** - Azureサービス情報
   - `Id` (NVARCHAR(200), PK) - サービスID
   - `Name` (NVARCHAR(200), NOT NULL) - サービス名
   - `Type` (NVARCHAR(200)) - サービス種類
   - `DisplayName` (NVARCHAR(200)) - 表示名
   - `ResourceType` (NVARCHAR(600)) - リソースタイプ
   - `created_at` (DATETIME2, DEFAULT GETDATE()) - 作成日時
   - `create_user` (NVARCHAR(200), NULL) - 作成者
   - `updated_at` (DATETIME2, DEFAULT GETDATE()) - 更新日時
   - `update_user` (NVARCHAR(200), NULL) - 更新者

### 作成されるインデックス

- `IX_Users_Email` - Users.Email
- `IX_Products_Name` - Products.Name
- `IX_Orders_UserId` - Orders.UserId
- `IX_Orders_OrderDate` - Orders.OrderDate

### 作成されるビュー

- **vw_UserOrders** - ユーザーと注文情報の結合ビュー
  - ユーザー名、メールアドレス、注文ID、注文日時、合計金額、ステータスを表示

### 作成されるストアドプロシージャ

- **sp_GetUserOrders** - 指定ユーザーの注文履歴を取得
  - パラメータ: `@UserId INT`
  - 戻り値: 注文情報、商品名、数量、単価

### サンプルデータ

#### Users テーブル
- 田中太郎 (tanaka@example.com, 30歳)
- 佐藤花子 (sato@example.com, 25歳)
- 鈴木一郎 (suzuki@example.com, 35歳)
- 高橋美咲 (takahashi@example.com, 28歳)

#### Products テーブル
- ノートパソコン (¥150,000, 在庫10台)
- スマートフォン (¥80,000, 在庫20台)
- タブレット (¥50,000, 在庫15台)
- ワイヤレスイヤホン (¥15,000, 在庫30台)

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

### サービスの状態確認

```bash
# 仮想マシン内で実行
docker service ls

# サービスの詳細情報を確認
docker service ps sqlserver-stack_sqlserver
```

### データベースへの接続

**注意**: `sqlcmd`を対話モードで使用する場合は、`-it`オプションが必要です。これにより、TTY（ターミナル）に接続して対話的にSQLコマンドを実行できます。

```bash
# コンテナ内でSQL Serverに接続（対話モード）
docker exec -it $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N

# データベース一覧の確認（単一クエリ実行）
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -Q "SELECT name FROM sys.databases"

# テーブル一覧の確認（単一クエリ実行）
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -Q "USE TestDB; SELECT table_name FROM information_schema.tables WHERE table_type = 'BASE TABLE'"

# 見やすい表示でのテーブル一覧確認
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -h -1 -s "," -Q "USE TestDB; SELECT table_name FROM information_schema.tables WHERE table_type = 'BASE TABLE'"
```

### バックアップの作成

```bash
# データベースのバックアップを作成
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -Q "BACKUP DATABASE TestDB TO DISK = '/backups/TestDB_$(date +%Y%m%d_%H%M%S).bak'"
```

### データの復元

```bash
# バックアップからデータを復元
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -Q "RESTORE DATABASE TestDB FROM DISK = '/backups/TestDB_20231201_120000.bak'"
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
docker stack rm sqlserver-stack
docker volume rm sqlserver_sqlserver_data
```

## 📝 サンプルクエリ

**重要**: `sqlcmd`でSQLコマンドを実行する場合、各コマンドの後に`GO`を入力する必要があります。`GO`はバッチの終了を示し、SQLコマンドを実行するためのトリガーとなります。

**表示の改善**: デフォルトの出力は見づらいため、以下のオプションを使用することを推奨します：
- `-h -1`: ヘッダーを無効化
- `-s ","`: カンマ区切りで出力
- `-W`: 列幅を調整

**NVARCHARの表示問題**: `NVARCHAR(200)`は可変長文字列ですが、`sqlcmd`のデフォルト表示では列の最大幅（200文字分）で固定幅表示されるため、短い文字列でも空白埋めされて見づらくなります。解決策として：
- `LEFT()`関数で列幅を制限
- `-W`オプションで列幅を自動調整
- `-s ","`でCSV形式で出力

### 基本的なクエリ

#### ユーザー一覧の取得
```sql
USE TestDB;
SELECT * FROM Users;
GO
```

#### 商品一覧の取得
```sql
USE TestDB;
SELECT * FROM Products;
GO
```

#### 注文一覧の取得
```sql
USE TestDB;
SELECT * FROM Orders;
GO
```

#### AzureServices一覧の取得
```sql
USE TestDB;
SELECT * FROM AzureServices;
GO
```

**列幅を制限した見やすいクエリ**:  
ただし -W でも問題なさそう
```sql
USE TestDB;
SELECT 
    LEFT(Id, 50) AS Id,
    LEFT(Name, 30) AS Name,
    LEFT(Type, 30) AS Type,
    LEFT(DisplayName, 30) AS DisplayName,
    LEFT(ResourceType, 50) AS ResourceType
FROM AzureServices;
GO
```

**見やすい表示オプション**:
```bash
# ヘッダーなし、カンマ区切りで表示
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -h -1 -s "," -Q "USE TestDB; SELECT TOP 5 * FROM AzureServices;"

# 列幅調整で表示
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -W -Q "USE TestDB; SELECT TOP 5 * FROM AzureServices;"

# 列幅を明示的に指定して表示
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -h -1 -s "," -Q "USE TestDB; SELECT TOP 5 Id, Name, Type, DisplayName, ResourceType FROM AzureServices;"
```

### 結合クエリ

#### ユーザーと注文情報の結合
```sql
USE TestDB;
SELECT 
    u.Name,
    u.Email,
    o.Id AS OrderId,
    o.OrderDate,
    o.TotalAmount,
    o.Status
FROM Users u
INNER JOIN Orders o ON u.Id = o.UserId;
GO
```

#### 注文詳細の取得
```sql
USE TestDB;
SELECT 
    o.Id AS OrderId,
    u.Name AS UserName,
    p.Name AS ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice) AS SubTotal
FROM Orders o
INNER JOIN Users u ON o.UserId = u.Id
INNER JOIN OrderDetails od ON o.Id = od.OrderId
INNER JOIN Products p ON od.ProductId = p.Id;
GO
```

### 集計クエリ

#### 商品別売上集計
```sql
USE TestDB;
SELECT 
    p.Name AS ProductName,
    SUM(od.Quantity) AS TotalSold,
    SUM(od.Quantity * od.UnitPrice) AS TotalRevenue,
    AVG(od.UnitPrice) AS AveragePrice
FROM Products p
LEFT JOIN OrderDetails od ON p.Id = od.ProductId
GROUP BY p.Name, p.Id
ORDER BY TotalRevenue DESC;
GO
```

#### ユーザー別購入金額集計
```sql
USE TestDB;
SELECT 
    u.Name,
    u.Email,
    COUNT(o.Id) AS OrderCount,
    SUM(o.TotalAmount) AS TotalSpent,
    AVG(o.TotalAmount) AS AverageOrderValue
FROM Users u
LEFT JOIN Orders o ON u.Id = o.UserId
GROUP BY u.Id, u.Name, u.Email
ORDER BY TotalSpent DESC;
GO
```

### ストアドプロシージャの使用

#### ユーザーの注文履歴
```sql
USE TestDB;
EXEC sp_GetUserOrders @UserId = 1;
GO
```

### ビューの使用

#### ユーザー注文ビューの確認
```sql
USE TestDB;
SELECT * FROM vw_UserOrders;
GO
```

### 条件付きクエリ

#### 高額注文の検索（10万円以上）
```sql
USE TestDB;
SELECT 
    u.Name,
    o.Id AS OrderId,
    o.TotalAmount,
    o.OrderDate
FROM Orders o
INNER JOIN Users u ON o.UserId = u.Id
WHERE o.TotalAmount >= 100000
ORDER BY o.TotalAmount DESC;
GO
```

#### 在庫不足商品の検索（在庫5個以下）
```sql
USE TestDB;
SELECT 
    Name,
    Description,
    Price,
    StockQuantity
FROM Products
WHERE StockQuantity <= 5
ORDER BY StockQuantity ASC;
GO
```

#### 最近の注文（過去30日）
```sql
USE TestDB;
SELECT 
    u.Name,
    o.Id AS OrderId,
    o.OrderDate,
    o.TotalAmount
FROM Orders o
INNER JOIN Users u ON o.UserId = u.Id
WHERE o.OrderDate >= DATEADD(day, -30, GETDATE())
ORDER BY o.OrderDate DESC;
GO
```

### 統計クエリ

#### 月別売上統計
```sql
USE TestDB;
SELECT 
    YEAR(o.OrderDate) AS Year,
    MONTH(o.OrderDate) AS Month,
    COUNT(o.Id) AS OrderCount,
    SUM(o.TotalAmount) AS TotalRevenue,
    AVG(o.TotalAmount) AS AverageOrderValue
FROM Orders o
GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate)
ORDER BY Year DESC, Month DESC;
GO
```

#### 商品カテゴリ別分析
```sql
USE TestDB;
SELECT 
    CASE 
        WHEN p.Price >= 100000 THEN '高額商品'
        WHEN p.Price >= 50000 THEN '中額商品'
        ELSE '低額商品'
    END AS PriceCategory,
    COUNT(p.Id) AS ProductCount,
    AVG(p.Price) AS AveragePrice,
    SUM(p.StockQuantity) AS TotalStock
FROM Products p
GROUP BY 
    CASE 
        WHEN p.Price >= 100000 THEN '高額商品'
        WHEN p.Price >= 50000 THEN '中額商品'
        ELSE '低額商品'
    END;
GO
```

## 🔄 開発ワークフロー

### 1. 開発開始時

```bash
# ホストマシンで実行
vagrant up
vagrant ssh

# 仮想マシン内で実行
cd /vagrant/SQLServer
./deploy-stack.sh
```

### 2. 開発終了時

```bash
# 仮想マシン内で実行
docker stack rm sqlserver-stack

# 仮想マシンから抜ける
exit

# ホストマシンで実行（必要に応じて）
vagrant halt
```

### 3. コード変更時の反映

```bash
# 仮想マシン内で実行
cd /vagrant/SQLServer
docker stack rm sqlserver-stack
./deploy-stack.sh
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

### サービスが起動しない場合

```bash
# 仮想マシン内でログを確認
docker service logs sqlserver-stack_sqlserver

# サービスを再作成
docker stack rm sqlserver-stack
./deploy-stack.sh
```

### データベースが作成されない場合

```bash
# 初期化スクリプトのログを確認
docker service logs sqlserver-stack_sqlserver | grep -i "initialization\|database"

# 手動でデータベースを初期化
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd -C -N -i /docker-entrypoint-initdb.d/01-create-database.sql

# 初期化スクリプトの権限を確認
docker exec $(docker ps -q -f name=sqlserver-stack_sqlserver) ls -la /init-db.sh
```

### 接続できない場合

1. 仮想マシンが起動しているか確認
2. ポート1433が他のアプリケーションで使用されていないか確認
3. ファイアウォールの設定を確認
4. SQL Serverが完全に起動するまで数分待機

### パスワードエラーの場合

```bash
# サービスを停止して再起動
docker stack rm sqlserver-stack
./deploy-stack.sh
```

### ファイル同期の問題

```bash
# 仮想マシンを再起動
vagrant reload

# または仮想マシンを再作成
vagrant destroy
vagrant up
```

## 🚀 Docker Swarm の利点

このプロジェクトではDocker Swarmを使用することで、以下の利点があります：

1. **スケーラビリティ**: 必要に応じてサービスをスケールアップ/ダウン可能
2. **高可用性**: サービス障害時の自動復旧
3. **ロードバランシング**: 複数のインスタンス間での自動負荷分散
4. **サービスディスカバリ**: サービス間の自動的な名前解決
5. **セキュリティ**: Swarmの暗号化された通信
6. **管理の簡素化**: 単一のコマンドでサービス全体を管理

## 📚 参考リンク

- [SQL Server Docker Hub](https://hub.docker.com/_/microsoft-mssql-server)
- [SQL Server ドキュメント](https://docs.microsoft.com/ja-jp/sql/sql-server/)
- [Docker Swarm ドキュメント](https://docs.docker.com/engine/swarm/)
- [Vagrant ドキュメント](https://www.vagrantup.com/docs)
- [AlmaLinux ドキュメント](https://almalinux.org/) 
