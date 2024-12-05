#!/usr/bin/env bats

setup() {
  load "${BATS_PLUGIN_PATH}/load.bash"

  # Uncomment to enable stub debugging
  # export GIT_STUB_DEBUG=/dev/tty

  # Common test variables
  export BUILDKITE_COMMIT="current-sha"
  export BUILDKITE_BRANCH="feature-branch"
  export BUILDKITE_BUILD_NUMBER="123"

  # Create and clean up temp directory
  export BATS_TMPDIR="${BATS_TEST_TMPDIR}"
  mkdir -p "${BATS_TMPDIR}"
}

teardown() {
  rm -rf "${BATS_TMPDIR}"
}

@test "Creates annotation comparing against previous commit when no branch specified" {
  stub mktemp "echo '${BATS_TMPDIR}/diff.md'"

  stub git \
    "rev-parse current-sha^1 : echo previous-sha" \
    "diff --color=always previous-sha current-sha : echo 'diff output'" \
    "diff --numstat previous-sha current-sha : echo '1  2  file.txt'"

  stub buildkite-agent "annotate '*' --context '*' --style 'info' --append : echo Annotation created"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Annotation created"

  unstub git
  unstub buildkite-agent
  unstub mktemp
}

@test "Compares against specified branch using merge-base" {
  export BUILDKITE_PLUGIN_ANNOTATE_GIT_DIFF_COMPARE_BRANCH="main"
  export BUILDKITE_PLUGIN_ANNOTATE_GIT_DIFF_INCLUDE_MERGE_BASE="true"

  stub mktemp "echo '${BATS_TMPDIR}/diff.md'"

  stub git \
    "fetch origin main : echo 'Fetching main'" \
    "merge-base origin/main current-sha : echo merge-base-sha" \
    "diff --color=always merge-base-sha current-sha : echo 'diff output'" \
    "diff --numstat merge-base-sha current-sha : echo '1  2  file.txt'"

  stub buildkite-agent "annotate '*' --context '*' --style 'info' --append : echo Annotation created"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Fetching main"
  assert_output --partial "Annotation created"

  unstub git
  unstub buildkite-agent
  unstub mktemp
}

@test "Compares directly against branch head when merge-base disabled" {
  export BUILDKITE_PLUGIN_ANNOTATE_GIT_DIFF_COMPARE_BRANCH="main"
  export BUILDKITE_PLUGIN_ANNOTATE_GIT_DIFF_INCLUDE_MERGE_BASE="false"

  stub mktemp "echo '${BATS_TMPDIR}/diff.md'"

  stub git \
    "fetch origin main : echo 'Fetching main'" \
    "rev-parse origin/main : echo main-head-sha" \
    "diff --color=always main-head-sha current-sha : echo 'diff output'" \
    "diff --numstat main-head-sha current-sha : echo '1  2  file.txt'"

  stub buildkite-agent "annotate '*' --context '*' --style 'info' --append : echo Annotation created"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Fetching main"
  assert_output --partial "Annotation created"

  unstub git
  unstub buildkite-agent
  unstub mktemp
}

@test "Uses markdown format by default" {
  stub mktemp "echo '${BATS_TMPDIR}/diff.md'"

  stub git \
    "rev-parse current-sha^1 : echo previous-sha" \
    "diff --color=always previous-sha current-sha : echo '+new line'" \
    "diff --numstat previous-sha current-sha : echo '1  2  file.txt'"

  stub buildkite-agent "annotate '*' --context '*' --style 'info' --append : echo Annotation created"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Annotation created"

  unstub git
  unstub buildkite-agent
  unstub mktemp
}

@test "Respects raw diff format when specified" {
  export BUILDKITE_PLUGIN_ANNOTATE_GIT_DIFF_FORMAT="diff"

  stub mktemp "echo '${BATS_TMPDIR}/diff.md'"

  stub git \
    "rev-parse current-sha^1 : echo previous-sha" \
    "diff --color=always previous-sha current-sha : echo 'raw diff output'"

  stub buildkite-agent "annotate '*' --context '*' --style 'info' --append : echo Annotation created"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Annotation created"

  unstub git
  unstub buildkite-agent
  unstub mktemp
}

@test "Handles empty diff output" {
  stub mktemp "echo '${BATS_TMPDIR}/diff.md'"

  stub git \
    "rev-parse current-sha^1 : echo previous-sha" \
    "diff --color=always previous-sha current-sha : echo ''" \
    "diff --numstat previous-sha current-sha : echo ''"

  stub buildkite-agent "annotate '*' --context '*' --style 'info' --append : echo Annotation created"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Annotation created"

  unstub git
  unstub buildkite-agent
  unstub mktemp
}
