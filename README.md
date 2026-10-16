# go-repo

Doc-ID: README-GO-REPO
Version: 3.8.0
Updated-UTC: 2026-10-16T22:03:26Z

Golang repository template with a Makefile, linting, security scanning, and GitHub Actions CI.

## Requirements

- Go 1.27 or newer

Dev tools (`golangci-lint` v2.14.0, `govulncheck` v1.9.0, `hadolint` v2.15.1) are installed into `bin/` by `make tools`, which `make lint`, `make vuln`, and `make dockerlint` depend on. Every version is pinned and declared once: `golangci-lint` in `.golangci-lint-version` (read by both the `Makefile` and the CI workflow), `govulncheck` in `GOVULNCHECK_VERSION`, and `hadolint` in `HADOLINT_VERSION`. `bin/` is git-ignored, so no global install is required.

## Layout

Highlights of the tree, not an exhaustive listing; `make help` lists every target.

```
cmd/dummy/          entry point (wiring only)
internal/greet/     library code and its tests
docs/architecture/  C4 diagrams as Mermaid source
.githooks/          git hooks, activated by `make install-pre-commit`
Dockerfile          multi-stage build, distroless non-root runtime
compose.yaml        service definition for the image
.hadolint.yaml      hadolint severity policy
```

## Commands

| Command | Purpose |
| --- | --- |
| `make build` | Build `bin/go-repo` from `./cmd/dummy`, stamping `main.version` from `VERSION` (default `dev`) |
| `make run` | Run `./cmd/dummy` |
| `make test` | Run tests with `-race -shuffle=on` |
| `make coverage` | Write `coverage.out` and print total coverage |
| `make coverage-check` | Enforce the coverage floor on `./internal/...` (`COVERAGE_MIN`, default 80) |
| `make tools` | Install pinned `golangci-lint`, `govulncheck`, and `hadolint` into `bin/` |
| `make lint` | `golangci-lint run` (vet, format check, and linters) |
| `make lint-fix` | Apply `golangci-lint` autofixes |
| `make vuln` | `govulncheck ./...` |
| `make dockerlint` | Lint `Dockerfile` with hadolint |
| `make pre-commit` | Lint, test, coverage floor, and `dockerlint`; what the git hook runs |
| `make install-pre-commit` | Point `core.hooksPath` at `.githooks` so the hook runs |
| `make clean` | Remove `bin/` and `coverage.out` |
| `make help` | List every target |

`make lint` is the single gate: golangci-lint's `govet` and `gofumpt` reproduce `go vet` and `gofmt -s` (including the simplification pass), so separate `go vet` and `gofmt` steps are redundant.

## CI

- `.github/workflows/ci.yaml` — on push to `main` and on pull requests: `lint`, `test` (`-race -shuffle=on`, a `go mod tidy` drift check, and the `make coverage-check` floor), `dockerlint` (hadolint), and `vuln` (`govulncheck`). A push to `main` that only touches docs is skipped; pull requests always run so required checks never stall. In-progress runs for the same ref are cancelled.
- `.github/workflows/codeql.yaml` — CodeQL `security-and-quality` on push to `main`, weekly, and on demand. Not run per pull request: it is the slowest job and the cheapest signal to defer.
- `.github/workflows/dependabot-automerge.yaml` — on Dependabot pull requests only: enables auto-merge so the pull request merges itself once the required checks pass. The ruleset on `main` requires `Lint`, `Dockerfile Lint`, `Test`, and `Vulnerability Check`; auto-merge waits for exactly those.
- `.github/workflows/release.yaml` — on push to `main` and on demand: bumps the version, pushes the tag, and creates the GitHub release with the generated changelog. The bump defaults to `patch`; a Conventional Commit type in the pull request title escalates it (`feat:` to minor, `feat!:` or `BREAKING CHANGE:` to major). No release artifacts are attached.

Dependencies are updated by Dependabot (`.github/dependabot.yml`) in three categories, each checked once a week on Monday and capped at one open pull request: `infra` (`docker`), `ci` (`github-actions`), and `code-lib` (`gomod`). Each category groups every dependency it owns into a single pull request, so a weekly run opens at most one bump per category. Dependabot rebases those pull requests automatically when the target branch moves. The three categories are staggered one hour apart in UTC (`infra` 04:00, `ci` 05:00, `code-lib` 06:00), so their pull requests never compete for the same checks or review window. The `time` input schedules only when Dependabot checks for updates; the merge itself happens whenever the required checks pass. Settings and rulesets are not inherited from a template, so a repository created from this one must enable `allow_auto_merge` and re-create the ruleset.

Contributor rules are mandatory and live in [AGENTS.md](AGENTS.md); they include test-driven development and C4 architecture modeling, with the diagrams under `docs/architecture/`.
