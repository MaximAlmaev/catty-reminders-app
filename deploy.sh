#!/bin/bash

echo "🚀 Начинаем развертывание демо-сайта..."

APP_DIR="/home/maxim/Desktop/catty-reminders-app"
APP_SERVICE="app.service"
ENV_FILE="/etc/app.env"
DEPLOY_REF="${DEPLOY_REF:-$(git rev-parse HEAD)}"

# Копируем файлы
echo "📁 Деплой $DEPLOY_REF в $APP_DIR"
sudo rsync -a --delete \
  --exclude '.git' \
  --exclude '.venv' \
  --exclude '__pycache__' \
  --exclude '*.pyc' \
  ./ "$APP_DIR"/
echo "DEPLOY_REF=$DEPLOY_REF" | sudo tee "$ENV_FILE" >/dev/null

echo "🔄 Перезапускаем сервис..."
sudo systemctl restart "$APP_SERVICE"

echo "✅ Деплой завершён: $DEPLOY_REF"
