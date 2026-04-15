#!/bin/bash

# 1. Create the Logstash Pipeline configuration
# This listens on port 5044 for Filebeat
sudo bash -c 'cat <<EOF > /etc/logstash/conf.d/k8s-pipeline.conf
input {
  beats {
    port => 5044
  }
}

filter {
  # This part helps identify that the logs are coming from your K8s cluster
  mutate {
    add_field => { "infrastructure" => "kubeadm-lab" }
  }
}

output {
  elasticsearch {
    hosts => ["http://localhost:9200"]
    index => "k8s-logs-%{+YYYY.MM.dd}"
  }
  # Useful for debugging: this prints logs to the Logstash service log too
  stdout { codec => rubydebug }
}
EOF'

# 2. Set ownership so the logstash user can run it
sudo chown -R logstash:logstash /etc/logstash/conf.d/

# 3. Enable and Restart Logstash
sudo systemctl daemon-reload
sudo systemctl enable logstash
sudo systemctl restart logstash