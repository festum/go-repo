.PHONY: all build clean coverage dep lint pre-commit install-pre-commit race run test install help

.DEFAULT_GOAL := build

all: dep test coverage build

run: ## Run app
	@go run .

build: ## Build binary file
	@mkdir -p bin
	@go build -v -o bin/$(shell basename $(CURDIR))
test: ## Run unittests
	@go test ./... -v -tags=test

lint: ## Lint and security checks
	@golangci-lint run --timeout=5m
pre-commit: ## Run mandatory checks before commit
	@if [ -n "$(shell go list ./... 2>/dev/null)" ]; then \
		$(MAKE) lint test; \
	else \
		echo "No Go packages, skipping lint/test"; \
	fi
race: dep ## Run data race detector
	@go test ./... -race -tags=test

coverage: ## Generate global code coverage report
	@go test ./... -cover -tags=test

dep: ## Get dependencies
	@go mod tidy
	@go mod download

install: dep ## Build and install binary file
	@mkdir -p bin
	@GOBIN=$(CURDIR)/bin go install -v ./...
clean: ## Remove previous built binary and clean packages
	@go mod tidy
	@rm -f ./bin/$(shell basename $(CURDIR))
install-pre-commit: ## Install local git pre-commit hook
	@mkdir -p .git/hooks
	@cp docs/hooks/pre-commit .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

