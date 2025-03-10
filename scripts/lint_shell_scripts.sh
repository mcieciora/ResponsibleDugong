#!/bin/bash

RETURN_VALUE=0
ALL_SHELL_FILES=$(find . -name "*.sh")

echo "$ALL_SHELL_FILES"

for SHELL_SCRIPT_NAME in $ALL_SHELL_FILES
do
  echo "Checking: $SHELL_SCRIPT_NAME"
  docker run --rm -i hadolint/hadolint < "$DOCKERFILE_VALUE"
  RETURN_CODE=$?
  if [ $RETURN_CODE -ne 0 ]; then
      echo "$DOCKERFILE_VALUE check failed."
      RETURN_VALUE=1
  fi
done

exit "$RETURN_VALUE"
