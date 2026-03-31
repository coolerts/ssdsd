#!/bin/bash
# ============================================
#  Официальный MTProxy — исправленная версия
# ============================================
set -e

echo "🛡 Установка официального MTProxy с поддержкой канала"

if ! command -v docker &>/dev/null; then
    echo "📦 Устанавливаю Docker..."
    apt-get update -qq && apt-get install -y -qq docker.io >/dev/null 2>&1
    systemctl enable --now docker >/dev/null 2>&1
fi

# Генерируем ЧИСТЫЙ секрет (строго 32 символа) для сервера и бота
BASE_SECRET=$(head -c 16 /dev/urandom | xxd -ps)

# Секрет для итоговой ссылки (с приставкой dd для обхода блокировок)
CLIENT_SECRET="dd${BASE_SECRET}"

IP=$(curl -4 -s ifconfig.me || curl -4 -s icanhazip.com || hostname -I | awk '{print $1}')

echo "🌐 IP сервера: $IP"
echo "🔑 Секрет (отправьте это боту @MTProxybot): $BASE_SECRET"

echo ""
echo "Если вы уже получили TAG от бота, введите его ниже."
echo "Если тега еще нет, просто нажмите Enter."
read -p "Ваш TAG (или пусто): " TAG_INPUT

docker rm -f mtproxy 2>/dev/null || true
docker volume create proxy-config >/dev/null 2>&1 || true

echo "🚀 Запускаю..."

if [ -z "$TAG_INPUT" ]; then
    # Запуск без тега. Передаем строго 32 символа!
    docker run -d -p 443:443 --name=mtproxy --restart=always -v proxy-config:/data -e SECRET=$BASE_SECRET telegrammessenger/proxy:latest >/dev/null
    echo "⚠️ Прокси запущен БЕЗ спонсорского канала."
else
    # Запуск с тегом
    docker run -d -p 443:443 --name=mtproxy --restart=always -v proxy-config:/data -e SECRET=$BASE_SECRET -e TAG=$TAG_INPUT telegrammessenger/proxy:latest >/dev/null
    echo "✅ Прокси запущен С тегом канала!"
fi

LINK="https://t.me/proxy?server=${IP}&port=443&secret=${CLIENT_SECRET}"

echo ""
echo "========================================="
echo "📎 Ссылка для подключения:"
echo "   $LINK"
echo "========================================="
