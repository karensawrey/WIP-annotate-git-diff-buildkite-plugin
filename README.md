# Git Diff Buildkite Plugin

A Buildkite plugin that shows the git diff between the current commit and its parent as a build annotation.

## Example

Add the following to your `pipeline.yml`:

```yaml
steps:
  - command: echo "Running with git diff..."
    plugins:
      - annotate-git-diff#v1.0.0:
          context: "my-diff"  # optional
          format: "markdown"  # optional (markdown|diff)
          compare_branch: "main"       # optional (defaults to the current branch)
          include_merge_base: true     # optional (defaults to true)
```

## Configuration

### `context` (optional)
The annotation context. Default: `git-diff`

### `format` (optional)
The output format for the diff. Can be either `markdown` or `diff`. Default: `markdown`

### `compare_branch` (optional)
The branch to compare against. Default: `the current branch`

### `include_merge_base` (optional)
When `true`, compares against the common ancestor of the current commit and target branch.
When `false`, compares directly against the HEAD of the target branch.
Default: `true`

## Development

To run the tests:

```bash
docker-compose run --rm tests
```

## License

MIT
