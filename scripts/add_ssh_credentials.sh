#!/bin/bash

set -e

function add_ssh_credentials() {
  echo "Creating SSH credentials"
  # shellcheck disable=SC2016
  JSON_STRING=$(printf '{
  "": "2",
  "credentials": {
    "scope": "GLOBAL",
    "id": "agent_%s",
    "description": "",
    "username": "jenkins_server",
    "privateKeySource": {
      "value": "0",
      "privateKey": "%s",
      "stapler-class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource",
      "$class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource"
    },
    "passphrase": "",
    "$class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
  }
}' "$AGENT_NAME" "$(cat "$SSH_PATH"/id_ed25519)")

  echo "$JSON_STRING" > curl_data.json

  curl -X POST "$JENKINS_URL/credentials/store/system/domain/_/createCredentials" --user "$JENKINS_ADMIN_USER:$TOKEN" -d @curl_data.json
}

add_ssh_credentials
