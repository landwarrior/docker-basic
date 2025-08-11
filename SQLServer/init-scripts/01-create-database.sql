-- テスト用データベースの作成
CREATE DATABASE TestDB;
GO

USE TestDB;
GO

-- ユーザーテーブルの作成
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    Age INT,
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- 商品テーブルの作成
CREATE TABLE Products (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(500),
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);
GO

-- 注文テーブルの作成
CREATE TABLE Orders (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    OrderDate DATETIME2 DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);
GO

-- 注文詳細テーブルの作成
CREATE TABLE OrderDetails (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(Id),
    FOREIGN KEY (ProductId) REFERENCES Products(Id)
);
GO

-- Azure サービステーブルの作成
CREATE TABLE AzureServices (
    Id NVARCHAR(200) PRIMARY KEY, -- ID
    Name NVARCHAR(200) NOT NULL, -- 名前
    Type NVARCHAR(200), -- 種類
    DisplayName NVARCHAR(200), -- 表示名
    ResourceType NVARCHAR(600), -- リソースタイプ
    created_at DATETIME2 DEFAULT GETDATE(), -- 作成日時（初期値: 現在日時）
    create_user NVARCHAR(200) NULL, -- 作成者
    updated_at DATETIME2 DEFAULT GETDATE(), -- 更新日時（初期値: 現在日時）
    update_user NVARCHAR(200) NULL -- 更新者
);
GO

-- サンプルデータの挿入
INSERT INTO Users (Name, Email, Age) VALUES 
    ('田中太郎', 'tanaka@example.com', 30),
    ('佐藤花子', 'sato@example.com', 25),
    ('鈴木一郎', 'suzuki@example.com', 35),
    ('高橋美咲', 'takahashi@example.com', 28);
GO

INSERT INTO Products (Name, Description, Price, StockQuantity) VALUES 
    ('ノートパソコン', '高性能なノートパソコン', 150000.00, 10),
    ('スマートフォン', '最新のスマートフォン', 80000.00, 20),
    ('タブレット', '軽量で使いやすいタブレット', 50000.00, 15),
    ('ワイヤレスイヤホン', '高音質ワイヤレスイヤホン', 15000.00, 30);
GO

-- インデックスの作成
CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Products_Name ON Products(Name);
CREATE INDEX IX_Orders_UserId ON Orders(UserId);
CREATE INDEX IX_Orders_OrderDate ON Orders(OrderDate);
GO

-- ビューの作成
CREATE VIEW vw_UserOrders AS
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

-- ストアドプロシージャの作成
CREATE PROCEDURE sp_GetUserOrders
    @UserId INT
AS
BEGIN
    SELECT 
        o.Id AS OrderId,
        o.OrderDate,
        o.TotalAmount,
        o.Status,
        p.Name AS ProductName,
        od.Quantity,
        od.UnitPrice
    FROM Orders o
    INNER JOIN OrderDetails od ON o.Id = od.OrderId
    INNER JOIN Products p ON od.ProductId = p.Id
    WHERE o.UserId = @UserId
    ORDER BY o.OrderDate DESC;
END
GO

PRINT 'データベースとテーブルの初期化が完了しました。';
GO 
