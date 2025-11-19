#!/bin/bash

# Скрипт начальной настройки Ubuntu Server
# Автоматизирует базовые настройки безопасности

echo "=== Начальная настройка Ubuntu Server ==="

# Шаг 1: Обновление системы
echo "1. Обновление пакетов..."
apt update && apt upgrade -y
apt install -y curl wget git htop nano vim ufw fail2ban

# Шаг 2: Создание пользователя myuser
echo "2. Создание пользователя myuser..."
adduser --gecos "" myuser
usermod -aG sudo myuser

# Шаг 3: Настройка SSH
echo "3. Настройка SSH..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

sudo tee /etc/ssh/sshd_config > /dev/null << EOF
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

sudo systemctl restart ssh

# Шаг 4: Настройка фаервола
echo "4. Настройка UFW..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp
sudo ufw --force enable

# Шаг 5: Настройка fail2ban
echo "5. Настройка fail2ban..."
sudo tee /etc/fail2ban/jail.local > /dev/null << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
backend = systemd

[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Шаг 6: Настройка автоматических обновлений
echo "6. Настройка автоматических обновлений..."
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Шаг 7: Настройка временной зоны
echo "7. Настройка временной зоны..."
sudo timedatectl set-timezone Europe/Moscow
sudo timedatectl set-ntp true

echo "=== Настройка завершена! ==="
echo "Важная информация:"
echo "- Создан пользователь: myuser"
echo "- SSH теперь на порту: 2222"
echo "- Вход по root запрещен"
echo "- Разрешена только аутентификация по ключам"
echo ""
echo "Не забудьте добавить свой SSH-ключ для пользователя myuser!"
echo "Команда для копирования ключа:"
echo "ssh-copy-id -p 2222 myuser@IP_АДРЕС_СЕРВЕРА"
