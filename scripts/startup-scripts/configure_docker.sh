#!/bin/bash
set -e

echo "=========== Configuring Docker ===========..."

# Create docker group and add vagrant user
sudo groupadd -f docker
sudo usermod -aG docker vagrant

# Ensure docker_home directory has proper permissions
sudo mkdir -p /var/docker_home
sudo chown -R vagrant:vagrant /var/docker_home

echo "=========== Docker configuration complete ========="
