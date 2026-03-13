module github.com/gardener/logcheck

// Version must be kept in sync with Go version of https://github.com/golangci/golangci-lint.
go 1.25.0

// This is a standalone go module for the logcheck linter
require (
	golang.org/x/exp v0.0.0-20251023183803-a4bb9ffd2546
	// this has to be kept in sync with the used golangci-lint version
	// use go version -m $(which golangci-lint) to detect the dependency versions
	golang.org/x/tools v0.42.0
)

require (
	golang.org/x/mod v0.33.0 // indirect
	golang.org/x/sync v0.19.0 // indirect
)

// Force x/tools version to match golangci-lint
replace golang.org/x/tools => golang.org/x/tools v0.39.0
