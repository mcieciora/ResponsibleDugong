#!/bin/bash

set -e

function add_ssh_credentials() {
  echo "Creating SSH credentials"
  echo "$TOKEN"
  echo "$HOME_PATH"
  curl -X POST "$JENKINS_URL/credentials/store/system/domain/_/createCredentials" --user "$JENKINS_ADMIN_USER:$TOKEN" \
  --data-urlencode 'json={
     "":"2",
     "credentials":{
        "scope":"GLOBAL",
        "id":"$1",
        "description":"",
        "username":"jenkins_server",
        "privateKeySource":{
           "value":"0",
           "privateKey":"$(cat /$HOME_PATH/.ssh/id_ed25519)",
           "stapler-class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource",
           "\$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource"
        },
        "passphrase":"",
        "$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
     }
  }'
}

add_ssh_credentials
