# Documentação do Processo de Criação e Configuração de Servidor Nginx na AWS
## Sobre o projeto

Este projeto envolve a criação e configuração de um servidor Nginx na AWS, utilizando recursos como VPC, instância EC2 e IP Elástico. O objetivo é configurar um servidor de monitoramento simples, onde o status do Nginx (online ou offline) é registrado em arquivos de log, e essas informações são exibidas em uma página web acessível publicamente.


## Índice

1. [Criação do VPC](#1-criação-do-vpc)
   - [Acessando o Console AWS](#11-acessando-o-console-aws)
   - [Configuração da VPC](#12-configuração-da-vpc)
   - [Definindo Parâmetros da VPC](#13-definindo-parâmetros-da-vpc)
2. [Criação da Instância EC2](#2-criação-da-instância-ec2)
   - [Associar um IP Elástico](#21-associar-um-ip-elástico)
3. [Configuração do Servidor Nginx](#3-configuração-do-servidor-nginx)
4. [Configuração do Script de Monitoramento](#4-configuração-do-script-de-monitoramento)
5. [Automatização com Cron](#5-automatização-com-cron)
6. [Demonstração do Status na Página Web](#6-demonstração-do-status-na-página-web)
7. [Considerações Finais](#7-considerações-finais)

---

## 1. Criação do VPC

### 1.1 Acessando o Console AWS

No console AWS, vá até o serviço VPC e clique em Criar VPC.

### 1.2 Configuração da VPC

  - No campo "Geração automática de etiqueta de nome", mantenha a opção marcada para gerar nomes automaticamente para os recursos.
  - Defina o prefixo desejado para as etiquetas de nome dos recursos.

### 1.3 Definindo Parâmetros da VPC

  - CIDR da VPC: 10.0.0.0/24 (Fornece 256 endereços IP).
  - Zonas de Disponibilidade (AZs): 1
  - Sub-redes públicas: 1
  - Sub-redes privadas: 0
  - Gateway NAT: Nenhum
  - VPC endpoints: Nenhum

## 2. Criação da Instância EC2

1. Acesse o console da AWS e vá para o serviço **EC2**.
2. Clique em **Launch Instances** e configure:
   - **Name**: `nginx-server`
   - **AMI**: Escolha `Ubuntu Server 22.04 LTS`.
   - **Instance type**: `t2.micro` (este é gratuito e adequado ao projeto).
   - **Key pair**: Selecione ou crie um novo par de chaves.
   - **Network settings**:
     - **VPC**: Selecione `my-vpc`.(adione a VPC criada no passo anterior)
     - **Subnet**: Selecione `my-subnet`.
     - **Auto-assign Public IP**: Enable.
   - **Security group**:
     - Permitir `SSH (Port 22)` e `HTTP (Port 80)`.
3. Clique em **Launch Instance**.

### 2.1 Associar um IP Elástico

1. Acesse o console da AWS e vá para **Elastic IPs**.
2. Clique em **Allocate Elastic IP address** e confirme.
3. Clique em **Actions** > **Associate Elastic IP address**.
4. Associe o IP à instância `nginx-server`.

---

## 3. Configuração do Servidor Nginx

1. Acesse a instância via SSH:
   ```bash
   ssh -i /path/to/key.pem ubuntu@<elastic-ip>
2. Atualize os pacotes do sistema:
   ```bash
   sudo apt update && sudo apt upgrade -y 
3. Instale o Nginx:
   ```bash
   sudo apt install nginx -y
4. Inicie o serviço Nginx:
   ```bash
   sudo systemctl start nginx
5. Habilite o serviço para iniciar automaticamente na inicialização:
   ```bash
   sudo systemctl enable nginx

---

## 4. Configuração do Script de Monitoramento

1. Crie os diretórios para armazenar os logs:
   ```bash
   sudo mkdir -p /var/log/nginx_status
   sudo chown -R ubuntu:ubuntu /var/log/nginx_status

2. Crie o script de monitoramento:
   ```bash
   sudo nano /usr/local/bin/nginx_status_monitor.sh 
3. Insira o seguinte conteúdo no script:
   ```bash
   #!/bin/bash

   ONLINE_LOG="/var/log/nginx_status/nginx_online.log"
   OFFLINE_LOG="/var/log/nginx_status/nginx_offline.log"

   STATUS=$(systemctl is-active nginx)
   DATA_HORA=$(date '+%Y-%m-%d %H:%M:%S')

   if [ "$STATUS" == "active" ]; then
       echo "$DATA_HORA - Serviço Nginx - ONLINE - O servidor está em execução." >> $ONLINE_LOG
   else
       echo "$DATA_HORA - Serviço Nginx - OFFLINE - O servidor está fora de operação." >> $OFFLINE_LOG
   fi

4. Dê permissões de execução ao script:
   ```bash
   sudo chmod +x /usr/local/bin/nginx_status_monitor.sh

---

## 5. Automatização com Cron

1. Abra o crontab para editar as tarefas agendadas:
   ```bash
   crontab -e
2. Adicione a seguinte linha para executar o script a cada minuto:
   ```bash
   */5 * * * * /usr/local/bin/nginx_status_monitor.sh 
3. Salve e saia do editor.

---

## 6. Demonstração do Status na Página Web

1. Crie um script para atualizar um arquivo HTML com os logs:
   ```bash
   sudo nano /usr/local/bin/update_status_page.sh
2. Insira o conteúdo:
   ```bash
      #!/bin/bash

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
3. Torne o script executável:
   ```bash
   sudo chmod +x /usr/local/bin/update_status_page.sh
4. Adicione o script ao cron para rodar a cada 5 minutos:
   ```bash
   */5 * * * * /usr/local/bin/update_status_page.sh
   
5. Acesse a página no navegador usando o IP público ou o DNS da instância:
   ```bash
   http://<elastic-ip>/status.html

---

## 7. Considerações Finais

  - O servidor está configurado para monitorar o status do Nginx e atualizar os logs automaticamente.
  - A página status.html reflete o status do servidor de forma simples e acessível.
  - Certifique-se de ajustar permissões e proteger informações sensíveis conforme necessário.
