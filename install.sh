#!/bin/bash

sudo apt-get update
sudo apt-get install -y docker.io nginx

sudo mkdir -p /var/log
sudo touch /var/log/devopsfetch.log


sudo cp devopsfetch.sh /usr/local/bin/devopsfetch
sudo chmod +x /usr/local/bin/devopsfetch

cat <<EOT | sudo tee /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch -m
Restart=always

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload
sudo systemctl enable devopsfetch.service
sudo systemctl start devopsfetch.service

echo "Installation complete. The devopsfetch service is now running."