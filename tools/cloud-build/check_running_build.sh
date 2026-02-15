#!/bin/bash
# Copyright 2026 "Google LLC"
set -e

TRIGGER_BUILD_CONFIG_PATH="$1"

# We use [[ ]] for string pattern matching. 
if [[ "$TRIGGER_BUILD_CONFIG_PATH" == *"onspot"* ]] && [[ "${_TEST_PREFIX}" == "pr-" ]]; then
    echo "DEBUG: 'onspot' PR test detected (Path: $TRIGGER_BUILD_CONFIG_PATH, Prefix: $_TEST_PREFIX)."
    echo "DEBUG: Skipping ongoing build check and returning success."
    exit 0
fi

echo "DEBUG: Proceeding with check for running builds..."

# 2. Existing logic to check for other running builds
echo "DEBUG: Checking for running builds matching trigger: $TRIGGER_BUILD_CONFIG_PATH"

# Filter out the current build ID to avoid a self-match (optional but cleaner)
# The current Build ID is available via the default $BUILD_ID variable
MATCHING_BUILDS=$(gcloud builds list --ongoing --format 'value(id)' \
    --filter="substitutions.TRIGGER_BUILD_CONFIG_PATH=\"$TRIGGER_BUILD_CONFIG_PATH\" AND id != \"$BUILD_ID\"")

# Check if the result is empty
if [ -n "$MATCHING_BUILDS" ]; then
        echo "Error: Found other running build(s) for this config:"
        echo "$MATCHING_BUILDS"
        exit 1
fi

echo "No other matching running builds found."