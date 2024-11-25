#!/bin/bash

set -e

function wait_for_jenkins_instance() {
  RETRY=1
  MAX_RETRIES=12

  while [ "$RETRY" -le "$MAX_RETRIES" ]; do
    echo "Retry: [$RETRY/$MAX_RETRIES]"
    if docker logs test_jenkins_instance 2>&1 | grep "Jenkins is fully up and running"; then
      echo "Jenkins is ready."
      return 0
    else
      RETRY=$((RETRY+1))
      echo "Jenkins is not fully booted yet, waiting 10 seconds..."
      sleep 10
    fi
  done
  echo "Jenkins instance is not running after 3 minutes. Terminating."
  return 1
}

function generate_crumb_and_token() {
  OUTPUT_FILE="token_data.json"
  JENKINS_URL="http://test_jenkins_instance:8080"
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
  echo "Token is: $TOKEN"
}

function test_setup_dsl_job() {
  curl "$JENKINS_URL/job/SetupDSLJobs/buildWithParameters?delay=0sec&token=$SECRET" --user "$JENKINS_USER:$TOKEN"
  echo "Sleeping for 30 seconds to let SetupDSLJobs finish..."
  sleep 30
  echo "Finished waiting."
  EXPECTED_JOBS_ARRAY=("SetupDSLJobs" "PythonDependenciesVerification_CarelessVaquita"
  "MultibranchPipeline_CarelessVaquita" "ScanDockerImages_CarelessVaquita" "ParametrizedTestPipeline_CarelessVaquita")
  echo "Getting list of all jobs..."
  MAIN_PAGE=$(curl "$JENKINS_URL/api/json?pretty=true" --user "$JENKINS_USER:$TOKEN")
  echo "$MAIN_PAGE" > "main_page.json"

  for JOB in "${EXPECTED_JOBS_ARRAY[@]}"; do
    jq -r ".jobs[].name" main_page.json | grep "$JOB"
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]; then
      echo "$JOB job is missing in Jenkins instance."
      exit 1
    else
      echo "pass"
    fi
  done

  EXPECTED_BRANCHES_ARRAY=("master" "develop")
  echo "Getting list of all branches..."
  MULTIBRANCH_PAGE=$(curl "$JENKINS_URL/job/MultibranchPipeline_CarelessVaquita/api/json?pretty=true" --user "$JENKINS_USER:$TOKEN")
  echo "$MULTIBRANCH_PAGE" > "multibranch_page.json"

  for BRANCH in "${EXPECTED_BRANCHES_ARRAY[@]}"; do
    jq -r ".jobs[].name" "multibranch_page.json" | grep "$BRANCH"
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]; then
      echo "$BRANCH branch is missing in Jenkins instance."
      exit 1
    else
      echo "pass"
    fi
  done
}

function test_jenkins_setup_utilities() {
  curl "$JENKINS_URL/job/SetupDSLJobs/buildWithParameters?delay=0sec&token=$SECRET&PROJECT_URL=https://github.com/mcieciora/ResponsibleDugong.git&PROJECT_NAME=ResponsibleDugong&BRANCH_NAME=$BRANCH_NAME" --user "$JENKINS_USER:$TOKEN"
  echo "Sleeping for 30 seconds to let SetupDSLJobs finish..."
  sleep 30
  echo "Finished waiting."
  EXPECTED_JOBS_ARRAY=("MultibranchPipeline_ResponsibleDugong" "CheckForNewestJenkinsVersionPipeline" "NodeSetupPipeline" "GenerateCRUMBPipeline" )
  echo "Getting list of all jobs..."
  MAIN_PAGE=$(curl "$JENKINS_URL/api/json?pretty=true" --user "$JENKINS_USER:$TOKEN")
  echo "$MAIN_PAGE" > "main_page.json"

  for JOB in "${EXPECTED_JOBS_ARRAY[@]}"; do
    jq -r ".jobs[].name" main_page.json | grep "$JOB"
    RET_VAL=$?
    if [ $RET_VAL -ne 0 ]; then
      echo "$JOB job is missing in Jenkins instance."
      exit 1
    else
      echo "pass"
    fi
  done
}

function test_on_next_jenkins_build_pipeline() {
  curl "$JENKINS_URL/job/TestOnNextJenkinsBuildPipeline/buildWithParameters?delay=0sec&token=$SECRET&BRANCH=$BRANCH_NAME" --user "$JENKINS_USER:$TOKEN"
  echo "Sleeping for 15 seconds to let TestOnNextJenkinsBuildPipeline finish..."
  sleep 15
  echo "Finished waiting."
  BUILD_RESULT=$(curl "$JENKINS_URL/job/TestOnNextJenkinsBuildPipeline/1/api/json?pretty=true" --user "$JENKINS_USER:$TOKEN")
  echo "$BUILD_RESULT" > "build_result.json"
  jq -r ".result" "build_result.json" | grep "SUCCESS"
  RET_VAL=$?
  if [ $RET_VAL -ne 0 ]; then
    echo "TestOnNextJenkinsBuildPipeline finished with result FAILURE. Obtaining full consoleText."
    curl "$JENKINS_URL/job/TestOnNextJenkinsBuildPipeline/1/consoleText" --user "$JENKINS_USER:$TOKEN"
    exit "$RET_VAL"
  fi
}

echo "Creating temporary service_network network"
docker network create --name jenkins_network service_network
echo "Launching Jenkins instance..."
docker run -d --name test_jenkins_instance --env-file .env_example --network jenkins_network jenkins_test_image
echo "Sleeping for 5 seconds before checking boot status..."
sleep 5

wait_for_jenkins_instance
generate_crumb_and_token
test_setup_dsl_job
test_jenkins_setup_utilities
test_on_next_jenkins_build_pipeline