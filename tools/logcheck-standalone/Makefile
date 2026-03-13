.PHONY: build build-plugin test clean

# Build the standalone binary
build:
	go build -o bin/logcheck .

# Build the golangci-lint plugin
build-plugin:
	CGO_ENABLED=1 go build -o bin/logcheck.so -buildmode=plugin ./plugin

# Run tests
test:
	go test -v ./...

# Clean build artifacts
clean:
	rm -rf bin/

# Install the tool
install:
	go install .

# Verify dependencies
verify:
	go mod verify
	go mod tidy -diff
