#!/bin/bash

set -e

echo "Creating SSH credentials"
ID_CONTENT=$(cat "$SSH_PATH"/id_ed25519)
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
         "privateKey":"$ID_CONTENT",
         "stapler-class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource",
         "\$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource"
      },
      "passphrase":"",
      "\$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
   }
}
EOF
)
echo 'json={
   "":"2",
   "credentials":{
      "scope":"GLOBAL",
      "id":"agent_'$AGENT_NAME'",
      "description":"",
      "username":"jenkins_server",
      "privateKeySource":{
         "value":"0",
         "privateKey":"'$(cat $SSH_PATH/id_ed25519)'",
         "stapler-class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource",
         "\$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource"
      },
      "passphrase":"",
      "$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
   }
}' > original_json.json
echo "$JSON_CONTENT" > curl_data.json
curl -X POST "$JENKINS_URL/credentials/store/system/domain/_/createCredentials" --user "$JENKINS_ADMIN_USER:$TOKEN" --data-binary @curl_data.json
