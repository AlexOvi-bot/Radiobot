#!/bin/bash
set -e

# Значения из окружения (Railway Variables)
: "${ICECAST_PASSWORD:=hackme}"
: "${MOUNT:=/stream}"
: "${TELEGRAM_TOKEN:=}"
: "${PLAYLIST_FILE:=playlist.txt}"

# Railway предоставляет переменную PORT для внешнего трафика
# Подставим её в icecast (если не задана, используем 8000)
PORT="${PORT:-8000}"

# Сгенерируем icecast.xml из шаблона (подставим пароль и порт)
sed -e "s|{{SOURCE_PASSWORD}}|${ICECAST_PASSWORD}|g" \
    -e "s|{{PORT}}|${PORT}|g" \
    /app/icecast.xml.template > /etc/icecast2/icecast.xml

# (опционально) Создадим папку для музыки, если есть volume
mkdir -p /data/music
# Если треки добавлены в репо, они будут в /app/music. При наличии volume можно монтировать в /data/music
if [ -d /data/music ] && [ "$(ls -A /data/music)" ]; then
  echo "Using /data/music for tracks"
  ln -sfn /data/music /app/music
fi

# Запускаем supervisord (он запустит icecast и bot)
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
