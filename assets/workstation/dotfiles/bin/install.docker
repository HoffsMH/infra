#! /bin/bash

echo "###############################################"
echo "Install Docker"
echo "###############################################"

yay -S --noconfirm \
  docker \
  docker-compose \

sudo usermod -aG docker $USER

sudo systemctl enable docker.service
sudo systemctl start docker.service
