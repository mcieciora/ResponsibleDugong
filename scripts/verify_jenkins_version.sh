#!/bin/bash

source ./.env_example

function generate_crumb_and_token() {
  echo "Sending crumb request..."
  CRUMB=$(curl "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)" --cookie-jar "$TOKEN_DIR/cookies.txt" --user "$JENKINS_USER:$JENKINS_PASSWORD")
  echo "Using crumb to get API token..."
  TOKEN_DATA=$(curl "$JENKINS_URL/user/$JENKINS_USER/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
  --user "$JENKINS_USER:$JENKINS_PASSWORD" --data "newTokenName=jenkins-version" --cookie "$TOKEN_DIR/cookies.txt" -H "$CRUMB")
  echo "Saving acquired API token..."
  echo "$TOKEN_DATA" > "$OUTPUT_FILE"
}

function get_stable_version() {
  echo "Getting last stable version..."
  STABLE=$(curl -L  https://updates.jenkins.io/stable/latestCore.txt)
  echo "$STABLE"
  printf '%s\n' "$STABLE" "$1" | sort -C -V
  RET_VAL=$?
  if [ $RET_VAL -ne 0 ]; then
    EXIT_VAL=2
    echo "Latest Jenkins stable version is $STABLE. Consider upgrading from $1"
  else
    echo "No newer stable version available."
  fi
}

function get_latest_version() {
  echo "Getting last latest version..."
  LATEST=$(curl -L  https://updates.jenkins.io/current/latestCore.txt)
  echo "$LATEST"
  printf '%s\n' "$LATEST" "$1" | sort -C -V
  RET_VAL=$?
  if [ $RET_VAL -ne 0 ]; then
    EXIT_VAL=2
    echo "$LATEST version is now available. Check it out: https://www.jenkins.io/changelog/$LATEST/"
  else
    echo "No newer latest version available."
  fi
}


EXIT_VAL=0
CURRENT_VERSION=$1
JENKINS_URL="$JENKINS_URL"
JENKINS_USER="$JENKINS_ADMIN_USER"
JENKINS_PASSWORD="$JENKINS_ADMIN_PASS"
TOKEN_DIR="$TOKEN_DIR"
OUTPUT_FILE="$TOKEN_DIR/token_data.json"

get_stable_version "$CURRENT_VERSION"
get_latest_version "$CURRENT_VERSION"

exit $EXIT_VAL
