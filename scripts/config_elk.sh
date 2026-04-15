#!/bin/bash

# 1. Force 1GB RAM limit (Overwrites to avoid duplicates)
sudo mkdir -p /etc/elasticsearch/jvm.options.d/
echo "-Xms1g" | sudo予 tee /etc/elasticsearch/jvm.options.d/memory.options
echo "-Xmx1g" | sudo tee -a /etc/elasticsearch/jvm.options.d/memory.options

# 2. Permanent OS limit fix for Elasticsearch 8.x
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

# 3. Clean and Minimal Elasticsearch Configuration
# We use a Here-Doc to overwrite the file completely to avoid "Duplicate Field" errors
sudo bash -c 'cat <<EOF > /etc/elasticsearch/elasticsearch.yml
cluster.name: my-kubeadm-lab
node.name: elk-server
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.type: single-node
xpack.security.enabled: false
xpack.security.enrollment.enabled: false
EOF'

# 4. Handle the Keystore (Removing the auto-generated secrets that cause Status 70)
sudo chown elasticsearch:elasticsearch /etc/elasticsearch/elasticsearch.keystore
sudo -u elasticsearch /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.transport.ssl.keystore.secure_password || true
sudo -u elasticsearch /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.transport.ssl.truststore.secure_password || true
sudo -u elasticsearch /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.http.ssl.keystore.secure_password || true

# 5. Fix Permissions
sudo chown -R elasticsearch:elasticsearch /etc/elasticsearch/
sudo chown -R elasticsearch:elasticsearch /var/lib/elasticsearch/
sudo chown -R elasticsearch:elasticsearch /var/log/elasticsearch/

# 6. Configure Kibana (Standardizing the file)
sudo sed -i 's/^#server.host:.*/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml
sudo sed -i 's|^#elasticsearch.hosts:.*|elasticsearch.hosts: ["http://localhost:9200"]|' /etc/kibana/kibana.yml

# 7. Start Services
sudo systemctl daemon-reload
sudo systemctl enable --now elasticsearch kibana