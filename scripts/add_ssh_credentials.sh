#!/bin/bash

set -e
source $(pwd)/.env_example


function generate_crumb_and_token() {
  OUTPUT_FILE="token_data.json"
  JENKINS_URL="http://localhost:8080"
  JENKINS_USER="$JENKINS_ADMIN_USER"
  JENKINS_PASSWORD="$JENKINS_ADMIN_PASS"
  echo "Sending crumb request..."
  CRUMB=$(curl "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)" --cookie-jar cookies.txt --user "$JENKINS_USER:$JENKINS_PASSWORD")
  echo "Using crumb to get API token..."
  TOKEN_DATA=$(curl "$JENKINS_URL/user/$JENKINS_USER/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
  --user "$JENKINS_USER:$JENKINS_PASSWORD" --data "newTokenName=jenkins-token" --cookie cookies.txt -H "$CRUMB")
  echo "Saving acquired API token..."
  echo "$TOKEN_DATA" > "$OUTPUT_FILE"
  TOKEN=$(jq -r ".data.tokenValue" "$OUTPUT_FILE")
  echo "$TOKEN"
}

function add_credentials() {
  echo "Creating SSH credentials"
  curl -X POST "$JENKINS_URL/credentials/store/system/domain/_/createCredentials" --user "$JENKINS_USER:$TOKEN" \
  --data-urlencode 'json={
     "":"2",
     "credentials":{
        "scope":"GLOBAL",
        "id":"github_id",
        "description":"",
        "username":"jenkins_server",
        "privateKeySource":{
           "value":"0",
           "privateKey":"$(cat /d/repos/ResponsibleDugong/.ssh_keys/id_ed25519)",
           "stapler-class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource",
           "\$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey\$DirectEntryPrivateKeySource"
        },
        "passphrase":"",
        "\$class":"com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
     }
  }'
}


generate_crumb_and_token
add_credentials
