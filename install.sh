#!/bin/bash
# ============================================
#  Официальный MTProxy — установка с каналом
# ============================================
set -e

echo "🛡 Установка официального MTProxy с поддержкой спонсорского канала"

# 1. Проверка Docker
if ! command -v docker &>/dev/null; then
    echo "📦 Устанавливаю Docker..."
    apt-get update -qq
    apt-get install -y -qq docker.io >/dev/null 2>&1
    systemctl enable --now docker >/dev/null 2>&1
fi

# 2. Генерируем секрет с поддержкой Random Padding (префикс dd для обхода DPI)
SECRET="dd$(head -c 16 /dev/urandom | xxd -ps)"
IP=$(curl -4 -s ifconfig.me || curl -4 -s icanhazip.com || hostname -I | awk '{print $1}')

echo "🌐 IP сервера: $IP"
echo "🔑 Секрет: $SECRET"

# 3. Запрос тега
echo ""
echo "Если вы уже зарегистрировали прокси в @MTProxybot и получили TAG,"
echo "введите его ниже. Если тега еще нет, просто нажмите Enter."
read -p "Ваш TAG (или пусто): " TAG_INPUT

# 4. Пересоздаем контейнер
docker rm -f mtproxy 2>/dev/null || true
docker volume create proxy-config >/dev/null 2>&1 || true

echo "🚀 Запускаю..."

if [ -z "$TAG_INPUT" ]; then
    # Запуск без тега
    docker run -d -p 443:443 --name=mtproxy --restart=always -v proxy-config:/data -e SECRET=$SECRET telegrammessenger/proxy:latest >/dev/null
    echo "⚠️ Прокси запущен БЕЗ спонсорского канала."
else
    # Запуск с тегом
    docker run -d -p 443:443 --name=mtproxy --restart=always -v proxy-config:/data -e SECRET=$SECRET -e TAG=$TAG_INPUT telegrammessenger/proxy:latest >/dev/null
    echo "✅ Прокси запущен С тегом канала!"
fi

LINK="https://t.me/proxy?server=${IP}&port=443&secret=${SECRET}"

echo ""
echo "========================================="
echo "📎 Ссылка для подключения:"
echo "   $LINK"
echo "========================================="
