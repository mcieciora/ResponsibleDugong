#!/bin/bash

set -e

echo "Creating SSH credentials"
JSON_CONTENT=$(cat <<EOF
  json={
     "":"2",
     "credentials":{
        "scope":"GLOBAL",
        "id":"agent_$AGENT_NAME",
        "description":"",
        "username":"jenkins_server",
        "privateKeySource":{
           "value":"0",
           "privateKey":$(cat "$SSH_PATH"/id_ed25519),
           "stapler-class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource",
           "\$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource"
        },
        "passphrase":"",
        "\$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
     }
  }
EOF
)
echo "$JSON_CONTENT" > curl_data.json
cat curl_data.json
curl -X POST "$JENKINS_URL/credentials/store/system/domain/_/createCredentials" --user "$JENKINS_ADMIN_USER:$TOKEN" -d @curl_data.json
