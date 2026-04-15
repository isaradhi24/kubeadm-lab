#!/bin/bash
############################################
# Configures SonarQube properly
# ✅ Sets admin password automatically
# ✅ Generates a Jenkins token via API
# ✅ Stores it for Jenkins usage
##################################################

set -e

echo "=========== Configuring SonarQube ===========..."

# Ensure proper ownership
sudo chown -R sonarqube:sonarqube /opt/sonarqube

# Update sonar.properties to bind to all network interfaces
SONAR_PROPERTIES="/opt/sonarqube/conf/sonar.properties"

sudo sed -i "s|#sonar.web.host=.*|sonar.web.host=0.0.0.0|" $SONAR_PROPERTIES
sudo sed -i "s|#sonar.web.port=.*|sonar.web.port=9000|" $SONAR_PROPERTIES

# Restart SonarQube to apply config
sudo systemctl restart sonarqube

echo "⏳ Waiting for SonarQube to be ready..."

# Wait until SonarQube is up
for i in {1..30}; do
  if curl -s http://localhost:9000/api/system/status | grep -q '"status":"UP"'; then
    echo "✅ SonarQube is UP"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 10
done

# ----------- Set Admin Password -----------
SONAR_URL="http://localhost:9000"
ADMIN_USER="admin"
ADMIN_DEFAULT_PASS="admin"
ADMIN_NEW_PASS="Bab@2442557Sarita

echo "🔐 Setting admin password..."

curl -u ${ADMIN_USER}:${ADMIN_DEFAULT_PASS} -X POST \
  "${SONAR_URL}/api/users/change_password" \
  -d "login=${ADMIN_USER}" \
  -d "password=${ADMIN_NEW_PASS}" \
  -s

# ----------- Generate Jenkins Token -----------
TOKEN_NAME="jenkins-token"

echo "🔑 Generating token for Jenkins..."

TOKEN_RESPONSE=$(curl -u ${ADMIN_USER}:${ADMIN_NEW_PASS} -X POST \
  "${SONAR_URL}/api/user_tokens/generate" \
  -d "name=${TOKEN_NAME}")

SONAR_TOKEN=$(echo $TOKEN_RESPONSE | grep -oP '"token":"\K[^"]+')

echo "✅ Token generated"

# Save token for Jenkins VM (shared path or manual copy)
echo $SONAR_TOKEN | sudo tee /vagrant/sonarqube_token.txt


# ----------- Wrapper Script -----------
cat <<'EOF' | sudo tee /usr/local/bin/start-sonarqube.sh
#!/bin/bash
cd /opt/sonarqube
./bin/linux-x86-64/sonar.sh start
EOF

sudo chmod +x /usr/local/bin/start-sonarqube.sh

echo "=========== SonarQube configuration complete ========="

IP=$(hostname -I | awk '{print $2}')

echo "👉 URL: http://${IP}:9000"
echo "👉 Admin Password: ${ADMIN_NEW_PASS}"
echo "👉 Token saved at: /vagrant/sonarqube_token.txt"