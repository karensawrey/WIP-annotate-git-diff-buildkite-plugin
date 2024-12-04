#!/usr/bin/env bats

setup() {
  load "${BATS_PLUGIN_PATH}/load.bash"

  # Uncomment to enable stub debugging
  # export GIT_STUB_DEBUG=/dev/tty
  
  # Common test variables
  export BUILDKITE_COMMIT="current-sha"
  export BUILDKITE_BRANCH="feature-branch"
  export BUILDKITE_BUILD_NUMBER="123"
}

@test "Creates annotation comparing against previous commit when no branch specified" {
  stub git \
    "rev-parse current-sha^1 : echo previous-sha" \
    "diff --color=never previous-sha current-sha : echo 'diff output'" \
    "diff --numstat previous-sha current-sha : echo '1  2  file.txt'"
  
  stub buildkite-agent \
    "annotate * : echo 'Creating annotation'"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Creating annotation"

  unstub git
  unstub buildkite-agent
}

@test "Compares against specified branch using merge-base" {
  export BUILDKITE_PLUGIN_GIT_DIFF_COMPARE_BRANCH="main"
  export BUILDKITE_PLUGIN_GIT_DIFF_INCLUDE_MERGE_BASE="true"

  stub git \
    "fetch origin main : echo 'Fetching main'" \
    "merge-base origin/main current-sha : echo merge-base-sha" \
    "diff --color=never merge-base-sha current-sha : echo 'diff output'" \
    "diff --numstat merge-base-sha current-sha : echo '1  2  file.txt'"

  stub buildkite-agent \
    "annotate * : echo 'Creating annotation'"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Creating annotation"

  unstub git
  unstub buildkite-agent
}

@test "Compares directly against branch head when merge-base disabled" {
  export BUILDKITE_PLUGIN_GIT_DIFF_COMPARE_BRANCH="main"
  export BUILDKITE_PLUGIN_GIT_DIFF_INCLUDE_MERGE_BASE="false"

  stub git \
    "fetch origin main : echo 'Fetching main'" \
    "rev-parse origin/main : echo main-head-sha" \
    "diff --color=never main-head-sha current-sha : echo 'diff output'" \
    "diff --numstat main-head-sha current-sha : echo '1  2  file.txt'"

  stub buildkite-agent \
    "annotate * : echo 'Creating annotation'"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Creating annotation"

  unstub git
  unstub buildkite-agent
}

@test "Uses markdown format by default" {
  stub git \
    "rev-parse current-sha^1 : echo previous-sha" \
    "diff --color=never previous-sha current-sha : echo '+new line'" \
    "diff --numstat previous-sha current-sha : echo '1  2  file.txt'"

  stub buildkite-agent \
    "annotate *--style \"info\"* : echo 'Creating markdown annotation'"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Creating markdown annotation"
  assert_output --partial ":green_heart: +new line"

  unstub git
  unstub buildkite-agent
}

@test "Respects raw diff format when specified" {
  export BUILDKITE_PLUGIN_GIT_DIFF_FORMAT="diff"

  stub git \
    "rev-parse current-sha^1 : echo previous-sha" \
    "diff --color=never previous-sha current-sha : echo 'raw diff output'" \

  stub buildkite-agent \
    "annotate * : echo 'Creating raw diff annotation'"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Creating raw diff annotation"

  unstub git
  unstub buildkite-agent
}

@test "Handles empty diff output" {
  stub git \
    "rev-parse current-sha^1 : echo previous-sha" \
    "diff --color=never previous-sha current-sha : echo ''" \
    "diff --numstat previous-sha current-sha : echo ''"

  stub buildkite-agent \
    "annotate * : echo 'Creating empty annotation'"

  run "$PWD"/hooks/pre-command

  assert_success
  assert_output --partial "Creating empty annotation"

  unstub git
  unstub buildkite-agent
}
