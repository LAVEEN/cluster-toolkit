#!/bin/bash
# Copyright 2026 "Google LLC"

set -e

TRIGGER_BUILD_CONFIG_PATH="$1"
TEST_PREFIX="$2"  # Expected: "pr-" or "daily-"

echo "Config Path: $TRIGGER_BUILD_CONFIG_PATH"
echo "Test Prefix: $TEST_PREFIX"

# We filter by BOTH the config path AND the specific test prefix 
# to ensure Daily and PR tests don't count against each other.
MATCHING_BUILDS=$(gcloud builds list --ongoing --format 'value(id)' \
  --filter="substitutions.TRIGGER_BUILD_CONFIG_PATH=\"$TRIGGER_BUILD_CONFIG_PATH\" AND substitutions._TEST_PREFIX=\"$TEST_PREFIX\"")

MATCHING_COUNT=$(echo "$MATCHING_BUILDS" | wc -w)

if [ "$MATCHING_COUNT" -gt 1 ]; then
  
  # CASE 1: PR Test on 'onspot' - Allow multiple
  if [[ "$TEST_PREFIX" == "pr-" && "$TRIGGER_BUILD_CONFIG_PATH" == *"onspot"* ]]; then
    echo "Found $MATCHING_COUNT matching PR builds. Allowing multiple for 'onspot' configuration."
    echo "$MATCHING_BUILDS"
    exit 0
  fi

  # CASE 2: Daily Test - Strictly only one allowed
  if [[ "$TEST_PREFIX" == "daily-" ]]; then
    echo "Error: A daily test is already running for this config. Only 1 allowed."
  else
    # This covers PR tests that are NOT 'onspot'
    echo "Error: Multiple matching builds found for $TEST_PREFIX ($TRIGGER_BUILD_CONFIG_PATH)."
  fi

  echo "Matching Build IDs:"
  echo "$MATCHING_BUILDS"
  exit 1
fi

echo "Check passed: No conflicting $TEST_PREFIX builds found."
exit 0