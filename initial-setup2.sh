#!/bin/bash
echo "Начальная настройка Ubuntu Server"

# Обновление системы
sudo apt-get update && apt-get upgrade -y
apt-get install -y curl wget git htop nano vim ufw fail2ban

# Создание пользователя myuser
adduser myuser
usermod -aG sudo myuser

# Настройка SSH
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

sudo echo "Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2" >> /etc/ssh/sshd_config

sudo systemctl restart ssh

# Настройка фаервола
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp # SSH на новом порту
sudo ufw allow 80/tcp # HTTP
sudo ufw allow 443/tcp # HTTPS
sudo ufw enable

# Настройка fail2ban
sudo echo "[DEFAULT]
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
bantime = 3600" >> /etc/fail2ban/jail.local


sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Настройка автоматических обновлений
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades

# Настройка автоматических обновлений

# Редактируем конфигурацию:
sudo nano /etc/apt/apt.conf.d/20auto-upgrades

# Добавляем:
sudo echo "APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";" >> /etc/apt/apt.conf.d/20auto-upgrades

