#!/bin/bash

# Update and install required packages
sudo apt-get update -y
sudo apt-get install -y nginx curl git unzip

# Install Node.js 20 and PM2
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2

# Clone repo (or pull if it already exists)
cd /home/ubuntu
git clone https://github.com/Cameronnosliw/tech613-cameron-node20-ttt-app.git app 2>/dev/null || (cd app && git pull)
cd /home/ubuntu/app

# Unzip and cd directly into the folder containing package.json
unzip -o nodejs20-sparta-tictactoe-v1.zip
cd "$(dirname "$(find . -maxdepth 3 -not -path '*/node_modules*' -name 'package.json' | head -n 1)")"

# 5. Install app dependencies and start with PM2
npm install
pm2 delete sparta-tictactoe 2>/dev/null || true
pm2 start index.js --name "sparta-tictactoe"

# Configure Nginx reverse proxy and restart
sudo sed -i 's|try_files $uri $uri/ =404;|proxy_pass http://localhost:3000/;|' /etc/nginx/sites-available/default
sudo systemctl restart nginx

pm2 status