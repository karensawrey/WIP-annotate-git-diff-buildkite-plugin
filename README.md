# Git Diff Buildkite Plugin

A Buildkite plugin that shows the git diff between the current commit and its parent as a build annotation.

## Example

Add the following to your `pipeline.yml`:

```yaml
steps:
  - command: echo "Running with git diff..."
    plugins:
      - git-diff#v1.0.0:
          context: "my-diff"  # optional
          format: "markdown"  # optional (markdown|diff)
```

## Configuration

### `context` (optional)
The annotation context. Default: `git-diff`

### `format` (optional)
The output format for the diff. Can be either `markdown` or `diff`. Default: `markdown`

## Development

To run the tests:

```bash
docker-compose run --rm tests
```

## License

MIT
