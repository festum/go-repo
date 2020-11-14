.PHONY: all build clean coverage dep lint race run test

.DEFAULT_GOAL := build

all: dep test coverage build

run: ## Run app
	@go run .

build: ## Build binary file
	@go build -v

test: ## Run unittests
	@go test ./... -v -tags=test

lint: ## Lint and security checks
	@golangci-lint run

race: dep ## Run data race detector
	@go test ./... -race -tags=test

coverage: ## Generate global code coverage report
	@go test ./... -cover -tags=test

dep: ## Get dependencies
	@go mod download

install: dep ## Build and install binary file
	@go install -v ./...

clean: ## Remove previous built binnay and keep latest lean packages
	@go mod tidy
	@rm -f ./$(basename `git rev-parse --show-toplevel`)

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

