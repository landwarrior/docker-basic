#!/bin/bash

# Docker Swarm スタックのデプロイスクリプト

STACK_NAME="sqlserver-stack"

echo "=== Docker Swarm SQLServer スタックデプロイ ==="

# スタックが既に存在する場合は削除
if docker stack ls | grep -q "$STACK_NAME"; then
    echo "既存のスタック $STACK_NAME を削除中..."
    docker stack rm $STACK_NAME
    sleep 10
fi

# スタックをデプロイ
echo "スタック $STACK_NAME をデプロイ中..."
docker stack deploy -c docker-compose.yml $STACK_NAME

# デプロイ状況を確認
echo "デプロイ状況を確認中..."
sleep 5
docker stack services $STACK_NAME

echo "=== デプロイ完了 ==="
echo "サービス一覧:"
docker service ls
echo ""
echo "スタック詳細:"
docker stack ps $STACK_NAME
