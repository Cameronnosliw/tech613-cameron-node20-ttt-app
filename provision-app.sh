#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# CONFIGURATION
REPO_URL="https://github.com/Cameronnosliw/tech613-cameron-node20-ttt-app.git"

sudo apt-get update -y
sudo apt-get install -y nginx curl git unzip

# Install Node.js 20 (only if not already installed)
if ! command -v node > /dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install PM2 globally (only if not already installed)
if ! command -v pm2 > /dev/null 2>&1; then
    sudo npm install -g pm2
fi

# Get the code from GitHub (if/else for idempotency)
cd /home/ubuntu
if [ -d "app/.git" ]; then
    echo "App directory exists, pulling changes"
    cd app
    git pull
else
    echo "Cloning app from GitHub repo"
    rm -rf app
    git clone "$REPO_URL" app
    cd app
fi

# Unzip app files if zipped
if [ -f "nodejs20-sparta-tictactoe-v1.zip" ]; then
    unzip -o nodejs20-sparta-tictactoe-v1.zip
fi

# Install app dependencies
npm install

# Start/restart the app with PM2
pm2 delete sparta-tictactoe 2>/dev/null || true
pm2 start index.js --name "sparta-tictactoe"
pm2 save

# Configure Nginx as a Reverse Proxy (Port 80 -> Port 3000)
sudo tee /etc/nginx/sites-available/default > /dev/null << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

# Restart Nginx to apply the reverse proxy settings
sudo systemctl restart nginx

# Show status table
pm2 status