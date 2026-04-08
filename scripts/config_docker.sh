#!/bin/bash
set -e

echo "=========== Configuring Docker ===========..."

# Create docker group and add vagrant user
groupadd -f docker
usermod -aG docker vagrant

# Ensure docker_home directory has proper permissions
mkdir -p /var/docker_home
chown -R vagrant:vagrant /var/docker_home

echo "=========== Docker configuration complete ========="