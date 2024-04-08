function generate_crumb_and_token() {
  echo "Sending crumb request..."
  CRUMB=$(curl "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,%22:%22,//crumb)" --cookie-jar "$DEST_DIR/cookies.txt" --user "$JENKINS_USER:$JENKINS_PASSWORD")
  echo "Using crumb to get API token..."
  TOKEN_DATA=$(curl "$JENKINS_URL/user/$JENKINS_USER/descriptorByName/jenkins.security.ApiTokenProperty/generateNewToken" \
  --user "$JENKINS_USER:$JENKINS_PASSWORD" --data "newTokenName=jenkins-version" --cookie "$DEST_DIR/cookies.txt" -H "$CRUMB")
  echo "Saving acquired API token..."
  echo "$TOKEN_DATA" > "$OUTPUT_FILE"
}

function get_stable_version() {
  STABLE=$(curl -L  https://updates.jenkins.io/stable/latestCore.txt)
  printf '%s\n' "$STABLE" "$1" | sort -C -V
  RET_VAL=$?
  if [ $RET_VAL -ne 0 ]; then
    EXIT_VAL=2
    echo "Latest Jenkins stable version is $STABLE. Consider upgrading from $1"
  fi
}

function get_latest_version() {
  LATEST=$(curl -L  https://updates.jenkins.io/current/latestCore.txt)
  printf '%s\n' "$LATEST" "$1" | sort -C -V
  RET_VAL=$?
  if [ $RET_VAL -ne 0 ]; then
    EXIT_VAL=2
    echo "$LATEST version is now available. Check it out: https://www.jenkins.io/changelog/$LATEST/"
  fi
}

function get_current_version() {
  if [ ! -f "$OUTPUT_FILE" ]; then
    generate_crumb_and_token
  fi
  TOKEN=$(jq -r ".data.tokenValue" "$OUTPUT_FILE")
  echo "Token is: $TOKEN"
  CURRENT_VERSION=$(curl "$JENKINS_URL" --user "$JENKINS_USER:$TOKEN" | grep 'X-Jenkins:' | awk '{print $2}')
  echo "$CURRENT_VERSION"
}


EXIT_VAL=0
JENKINS_URL="$JENKINS_URL"
JENKINS_USER="$JENKINS_ADMIN_USER"
JENKINS_PASSWORD="$JENKINS_ADMIN_PASS"
TOKEN_DIR="$TOKEN_DIR"
OUTPUT_FILE="$DEST_DIR/token_data.json"

CURRENT_VERSION=$(get_current_version)
get_stable_version "$CURRENT_VERSION"
get_latest_version "$CURRENT_VERSION"

exit $EXIT_VAL
