#!/bin/bash

ONLINE_LOG="/var/log/nginx-monitor/nginx_online.log"
OFFLINE_LOG="/var/log/nginx-monitor/nginx_offline.log"

STATUS=$(systemctl is-active nginx)

DATA_HORA=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$STATUS" == "active" ]; then
    echo "$DATA_HORA - Serviço Nginx - ONLINE - O servidor está em execução." >> $ONLINE_LOG
else
    echo "$DATA_HORA - Serviço Nginx - OFFLINE - O servidor está parado ou inativo." >> $OFFLINE_LOG
fi
