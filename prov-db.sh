#!/bin/bash

sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt install -y gnupg curl

curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | \
    sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor --yes

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | \
    sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

sudo apt update -y

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    mongodb-org=7.0.22 \
    mongodb-org-database=7.0.22 \
    mongodb-org-server=7.0.22 \
    mongodb-mongosh \
    mongodb-org-shell=7.0.22 \
    mongodb-org-mongos=7.0.22 \
    mongodb-org-tools=7.0.22 \
    mongodb-org-database-tools-extra=7.0.22

sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf

sudo systemctl daemon-reload
sudo systemctl enable mongod
sudo systemctl restart mongod

sudo systemctl status mongod --no-pager
echo "MongoDB deployment complete."
