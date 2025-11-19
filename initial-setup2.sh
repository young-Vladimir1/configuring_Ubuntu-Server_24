#!/bin/bash
echo "Начальная настройка Ubuntu Server"

# Обновление системы
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y curl wget git htop nano vim ufw fail2ban

# Создание пользователя myuser
sudo adduser --gecos "" --disabled-password myuser
sudo usermod -aG sudo myuser
sudo passwd
echo "1234"

# Настройка SSH
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

sudo tee -a /etc/ssh/sshd_config > /dev/null << EOF
Port 2222
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

sudo systemctl restart ssh

# Настройка фаервола
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
echo "y" | sudo ufw enable

# Настройка fail2ban
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

# Настройка автоматических обновлений
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades -f noninteractive

# Настройка конфигурации обновлений
sudo tee /etc/apt/apt.conf.d/20auto-upgrades > /dev/null << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF
