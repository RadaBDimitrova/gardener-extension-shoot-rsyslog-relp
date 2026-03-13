# logcheck

A Go linter for checking structured logging calls to `logr.Logger` instances.

## Description

This is a tool for checking structured logging calls to `logr.Logger` instances (inspired by [klog's logcheck](https://github.com/kubernetes/klog/tree/main/hack/tools/logcheck)).
It checks `Info`, `Error` and `WithValues` calls for common programmer-level errors.
For example, it verifies that:

- calls are made with key-value pairs (even number of variadic args)
- messages don't contain `printf` format specifiers (`%s` and friends)

Furthermore, it verifies compliance with several aspects of structured logging guidelines (e.g., constant messages and keys, capitalized messages, etc.).

## Motivation

The tool was created to support the migration from unstructured logging with `logrus` to structured logging with `logr`.
With this tool you will be able to prevent bugs caused by switching to a new logging style (e.g. panic due to odd number of args). Also, it helps to make logging in your components more consistent across the entire codebase.

## Checks Performed

- **Constant messages**: Log messages should be constant string expressions
- **Non-empty messages**: Log messages should not be empty
- **No format specifiers**: Messages should not contain `printf` format specifiers
- **Capitalized messages**: Log messages should start with uppercase letter
- **No trailing punctuation**: Log messages should not end with punctuation marks
- **Key-value pairs**: Variadic args must be in pairs (even number)
- **Constant keys**: Keys should be constant string expressions
- **Non-empty keys**: Keys should not be empty
- **lowerCamelCase keys**: Keys should be in lowerCamelCase format
- **ASCII keys**: Keys should contain only ASCII characters
- **No spaces in keys**: Keys should not contain whitespace

## Implementation Details

The tool is implemented using the [`golang.org/x/tools/go/analysis`](https://pkg.go.dev/golang.org/x/tools/go/analysis) package, which is a "linter framework" used by `go vet` and `golangci-lint` as well.

## Installation and Usage

There are two options for installing and using the `logcheck` tool:

- standalone binary: simple, but limited
- [`golangci-lint`](https://golangci-lint.run/) plugin (recommended): specific build requirements, but comes with caching, nice output, and flexible configuration options (e.g., excludes and `//nolint` comments) out of the box

### Standalone Binary

Install the tool with:

```bash
go install github.com/gardener/logcheck@latest
```

Use it with:
```bash
logcheck package [package...]
```

### [`golangci-lint`](https://golangci-lint.run/) Plugin (Recommended)

[`golangci-lint`](https://golangci-lint.run/) features a mechanism for loading [custom linters](https://golangci-lint.run/contributing/new-linters/#how-to-add-a-private-linter-to-golangci-lint) using Go's plugin library.

Build the plugin with:

```bash
CGO_ENABLED=1 go build -o logcheck.so -buildmode=plugin github.com/gardener/logcheck/plugin
```

> **Warning:** Both the `golangci-lint` binary and the `logcheck` plugin have to be built with `CGO_ENABLED=1` for the plugin mechanism to work. See [golangci/golangci-lint#1276](https://github.com/golangci/golangci-lint/issues/1276#issuecomment-665903858) for more details.
> This means, you can't use released binaries from GitHub or Homebrew for example, but have to build the binary yourself.

Load the plugin by adding the following to your `.golangci.yaml` configuration file:

```yaml
linters-settings:
  custom:
    logcheck:
      path: path/to/logcheck.so
      description: Check structured logging calls to logr.Logger instances
      original-url: github.com/gardener/logcheck
```

> **Note:** In order for the plugin mechanism to work, all versions of plugin dependencies that overlap with `golangci-lint` must be set to the same version. You can see the versions by running `go version -m golangci-lint`.

Now, `logcheck` is executed along with all other linters:

```bash
golangci-lint run ./...
```

## Running Tests

```bash
go test ./...
```

## License

Apache-2.0
