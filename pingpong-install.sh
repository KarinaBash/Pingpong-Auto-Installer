#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan script ini sebagai root."
  exit 1
fi

echo "Memperbarui dan meng-upgrade sistem..."
sudo apt update && sudo apt upgrade -y

echo "Menginstal Docker..."
sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update && sudo apt install -y docker-ce
sudo systemctl start docker
sudo systemctl enable docker

if systemctl is-active --quiet docker; then
  DOCKER_VERSION=$(docker --version)
  echo -e "Docker berhasil diinstal, diaktifkan, dan versi yang terpasang: $DOCKER_VERSION."
else
  echo "Docker gagal dijalankan. Periksa konfigurasi dan coba lagi."
  exit 1
fi

echo "Menginstal Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

if docker-compose --version > /dev/null 2>&1; then
  echo "Docker Compose versi $DOCKER_COMPOSE_VERSION berhasil diinstal."
else
  echo "Docker Compose gagal diinstal atau dijalankan. Periksa konfigurasi dan coba lagi."
  exit 1
fi

echo "Mengunduh Pingpong App..."
cd $HOME
wget https://pingpong-build.s3.ap-southeast-1.amazonaws.com/linux/latest/PINGPONG
chmod +x PINGPONG
echo "Pingpong App berhasil diunduh."

echo "Menginstal screen..."
sudo apt install -y screen
echo "screen berhasil diinstal."

echo -e "\nBuka tautan berikut untuk membuat Device ID:"
echo "https://harvester.pingpong.build/devices"
echo -e "\nSalin Device ID Anda dan jalankan aplikasi menggunakan langkah berikut:\n"
echo -e "screen -S pingpong"
echo -e "./PINGPONG --key DEVICE_ID_ANDA\n"

echo "Selamat mencoba mining!"
