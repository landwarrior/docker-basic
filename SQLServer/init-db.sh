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
