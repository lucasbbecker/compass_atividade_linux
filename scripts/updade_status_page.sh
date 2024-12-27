#!/bin/bash

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

OUTPUT_FILE="/var/www/html/status.html"
ONLINE_LOG="/var/log/nginx_status/nginx_online.log"
OFFLINE_LOG="/var/log/nginx_status/nginx_offline.log"

ULTIMA_LINHA_ONLINE=$(tail -n 1 $ONLINE_LOG 2>/dev/null)
ULTIMA_LINHA_OFFLINE=$(tail -n 1 $OFFLINE_LOG 2>/dev/null)

echo "<!DOCTYPE html>" > $OUTPUT_FILE
echo "<html lang='pt-BR'>" >> $OUTPUT_FILE
echo "<head><meta charset='UTF-8'><title>Status do Servidor</title></head>" >> $OUTPUT_FILE
echo "<body>" >> $OUTPUT_FILE
echo "<h1>Status do Servidor Nginx</h1>" >> $OUTPUT_FILE
echo "<p><strong>Último Status ONLINE:</strong> $ULTIMA_LINHA_ONLINE</p>" >> $OUTPUT_FILE
echo "<p><strong>Último Status OFFLINE:</strong> $ULTIMA_LINHA_OFFLINE</p>" >> $OUTPUT_FILE
echo "</body></html>" >> $OUTPUT_FILE