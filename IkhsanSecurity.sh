#!/bin/bash

echo "===== Telegram Bot Installer by Ikhsan ====="

# Cek NodeJS
if ! command -v node &> /dev/null
then
    echo "NodeJS belum terinstall, sedang menginstall..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
fi

# Buat folder bot
mkdir -p mytelebot
cd mytelebot

# Install dependensi
npm init -y
npm install node-telegram-bot-api

# Minta token
echo -n "8310449737:AAHC90hL6lkxvW3mIT2YQrii0Bnj4WvZdAI"
read token

# Simpan token ke config.json
cat <<EOF > config.json
{
  "token": "$token"
}
EOF

echo "Token berhasil disimpan di config.json"

# Buat script bot
cat <<EOF > bot.js
const fs = require("fs");
const TelegramBot = require("node-telegram-bot-api");

// Ambil token dari config
const config = JSON.parse(fs.readFileSync("./config.json"));
const bot = new TelegramBot(config.token, { polling: true });

bot.on("message", msg => {
    bot.sendMessage(msg.chat.id, "Bot aktif! Token permanen ✓");
});
EOF

# Buat service systemd agar bot auto-start
sudo bash -c 'cat <<EOF > /etc/systemd/system/telebot.service
[Unit]
Description=Telegram Bot
After=network.target

[Service]
Type=simple
WorkingDirectory='"$(pwd)"'
ExecStart=/usr/bin/node '"$(pwd)"'/bot.js
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable telebot
sudo systemctl start telebot

echo "Bot berhasil diinstall dan berjalan otomatis!"
echo "Gunakan perintah berikut:"
echo "  sudo systemctl start telebot"
echo "  sudo systemctl stop telebot"
echo "  sudo systemctl restart telebot"
