#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Mock git
function git() {
  if [[ "${1}" == "rev-parse" ]]; then
    echo "previous-sha"
  elif [[ "${1}" == "diff" ]]; then
    echo "diff --git a/file.txt b/file.txt"
    echo "index 1234567..89abcdef 100644"
    echo "--- a/file.txt"
    echo "+++ b/file.txt"
    echo "-old line"
    echo "+new line"
  fi
}

# Mock buildkite-agent
function buildkite-agent() {
  echo "Annotating build with diff"
}

@test "Creates annotation with default settings" {
  export BUILDKITE_COMMIT="current-sha"
  
  run "$PWD/hooks/pre-command"
  
  assert_success
  assert_output --partial "Annotating build with diff"
}

@test "Respects custom context" {
  export BUILDKITE_COMMIT="current-sha"
  export BUILDKITE_PLUGIN_GIT_DIFF_CONTEXT="custom-context"
  
  run "$PWD/hooks/pre-command"
  
  assert_success
  assert_output --partial "Annotating build with diff"
}
