#!/bin/bash

set -e

function add_ssh_credentials() {
  echo "Creating SSH credentials"
  PRIVATE_KEY="$(cat "$SSH_PATH"/id_ed25519)"

cat <<EOF > curl_data.json
{
  "": "2",
  "credentials": {
    "scope": "GLOBAL",
    "id": "agent_$AGENT_NAME",
    "description": "",
    "username": "jenkins_server",
    "privateKeySource": {
      "value": "0",
      "privateKey": "$PRIVATE_KEY",
      "stapler-class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource",
      "\$class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource"
    },
    "passphrase": "",
    "\$class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
  }
}
EOF

  curl -X POST "$JENKINS_URL/credentials/store/system/domain/_/createCredentials" --user "$JENKINS_ADMIN_USER:$TOKEN" -d @curl_data.json
}

add_ssh_credentials