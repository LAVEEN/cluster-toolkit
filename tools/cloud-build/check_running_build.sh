#!/bin/bash
set -e

# Assign values
TRIGGER_BUILD_CONFIG_PATH="${1:?Error: TRIGGER_BUILD_CONFIG_PATH argument is required}"
PREFIX="${_TEST_PREFIX:-}"

# Echo the assigned values immediately for logging
echo "--------------------------------------------------------"
echo "VARIABLE ASSIGNMENT:"
echo "TRIGGER_BUILD_CONFIG_PATH: $TRIGGER_BUILD_CONFIG_PATH"
echo "PREFIX (from _TEST_PREFIX): $PREFIX"
echo "--------------------------------------------------------"

# 1. Skip logic for 'onspot' PR tests
if [[ "$TRIGGER_BUILD_CONFIG_PATH" == *"onspot"* ]] && [[ "$PREFIX" == "pr-" ]]; then
    echo "MATCH DETECTED: 'onspot' config with 'pr-' prefix."
    echo "ACTION: Skipping ongoing build check."
    exit 0
fi

echo "DEBUG: No skip condition met. Proceeding with running build check..."

# 2. Check for other running builds
# We use single quotes inside the filter string to satisfy gcloud's parser
MATCHING_BUILDS=$(gcloud builds list --ongoing \
    --format='value(id)' \
    --filter="substitutions.TRIGGER_BUILD_CONFIG_PATH = '$TRIGGER_BUILD_CONFIG_PATH' AND id != '$BUILD_ID'")

if [ -n "$MATCHING_BUILDS" ]; then
    echo "ERROR: Found other running build(s) for this config:"
    echo "$MATCHING_BUILDS"
    exit 1
fi

echo "SUCCESS: No other matching builds found."