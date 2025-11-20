#!/bin/bash
echo "Начальная настройка Ubuntu Server"

# Шаг 1: Обновление системы
echo "1. Обновление пакетов..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git htop nano vim ufw fail2ban

# Шаг 2: Создание пользователя myuser
echo "2. Создание пользователя myuser..."
sudo adduser --gecos "" --disabled-password myuser
echo "1234" | sudo chpasswd
sudo usermod -aG sudo myuser

# Шаг 3: Настройка SSH
# echo "3. Настройка SSH..."
# sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# ВРЕМЕННО разрешаем пароли для первоначальной настройки
sudo tee -a /etc/ssh/sshd_config > /dev/null << EOF
Port 2222
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

sudo systemctl restart ssh

# Шаг 4: Настройка фаервола
echo "4. Настройка фаервола..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo "y" | sudo ufw enable

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
EOF

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Шаг 6: Настройка автоматических обновлений
echo "6. Настройка автоматических обновлений..."
sudo apt install -y unattended-upgrades

sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

# Шаг 7: Настройка временной зоны
# echo "7. Настройка временной зоны..."
# sudo timedatectl set-timezone Europe/Moscow
# sudo timedatectl set-ntp true
