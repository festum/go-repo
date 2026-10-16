# Doc-ID: MAKEFILE-GO-REPO
# Version: 3.5.0
# Updated-UTC: 2026-10-16T22:03:26Z

SHELL := /bin/sh
BINARY := $(shell go list -m | awk -F/ '{print $$NF}')
VERSION ?= dev
GO ?= go
TOOLS_BIN := $(CURDIR)/bin
GOLANGCI_LINT_VERSION ?= $(shell cat $(CURDIR)/.golangci-lint-version)
GOVULNCHECK_VERSION ?= v1.9.0
HADOLINT_VERSION ?= v2.15.1
GOLANGCI_LINT := $(TOOLS_BIN)/golangci-lint
GOVULNCHECK := $(TOOLS_BIN)/govulncheck
HADOLINT := $(TOOLS_BIN)/hadolint
HADOLINT_OS := $(shell uname -s | sed 's/Darwin/macos/;s/Linux/linux/')
HADOLINT_ARCH := $(shell uname -m | sed 's/aarch64/arm64/')
COVERAGE_MIN ?= 80

.PHONY: build clean coverage coverage-check dockerlint help install-pre-commit lint lint-fix \
	pre-commit run test tools vuln

.DEFAULT_GOAL := build

run: ## Run app
	@$(GO) run ./cmd/dummy

build: ## Build binary file
	@mkdir -p bin
	@$(GO) build -ldflags="-X main.version=$(VERSION)" -o bin/$(BINARY) ./cmd/dummy

test: ## Run unittests
	@$(GO) test ./... -race -shuffle=on

coverage: ## Generate global code coverage report
	@$(GO) test ./... -coverprofile=coverage.out
	@$(GO) tool cover -func=coverage.out | tail -1

coverage-check: ## Enforce the coverage floor on ./internal/...
	@$(GO) test ./internal/... -coverprofile=coverage.out >/dev/null
	@$(GO) tool cover -func=coverage.out | tail -1 | awk -v min=$(COVERAGE_MIN) '{gsub(/%/,"",$$3); if ($$3+0 < min) { printf "coverage %s%% < floor %s%%\n", $$3, min; exit 1 } else { printf "coverage %s%% >= floor %s%%\n", $$3, min }}'

tools: ## Install pinned dev tools into bin/
	@mkdir -p $(TOOLS_BIN)
	@test -x $(GOLANGCI_LINT) || GOBIN=$(TOOLS_BIN) $(GO) install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION)
	@test -x $(GOVULNCHECK) || GOBIN=$(TOOLS_BIN) $(GO) install golang.org/x/vuln/cmd/govulncheck@$(GOVULNCHECK_VERSION)
	@test -x $(HADOLINT) || { curl -fsSL -o $(HADOLINT) https://github.com/hadolint/hadolint/releases/download/$(HADOLINT_VERSION)/hadolint-$(HADOLINT_OS)-$(HADOLINT_ARCH) && chmod +x $(HADOLINT); }

lint: tools ## Lint, format check, and vet via golangci-lint
	@$(GOLANGCI_LINT) run --timeout=5m

lint-fix: tools ## Auto-fix lint and formatting issues
	@$(GOLANGCI_LINT) run --fix --timeout=5m

vuln: tools ## Scan dependencies for known vulnerabilities
	@$(GOVULNCHECK) ./...

dockerlint: tools ## Lint the Dockerfile with hadolint
	@$(HADOLINT) -c .hadolint.yaml Dockerfile

pre-commit: ## Run mandatory checks before commit
	@if [ -n "$$(go list ./... 2>/dev/null)" ]; then \
		$(MAKE) lint test coverage-check dockerlint; \
	else \
		echo "No Go packages, skipping lint/test"; \
	fi

clean: ## Remove built binaries, coverage output, and installed tools
	@rm -rf bin coverage.out

install-pre-commit: ## Point git at the tracked hooks directory
	@git config core.hooksPath .githooks
	@echo "core.hooksPath = $$(git config core.hooksPath)"

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'
