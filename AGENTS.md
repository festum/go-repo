# AGENTS Contract

Doc-ID: AGENTS-GO-REPO
Version: 3.10.0
Updated-UTC: 2026-10-16T22:03:26Z

## Scope

This file defines mandatory repository rules for human and agent contributors.

## Implementation standards

1. Go directory structure and implementation MUST follow the Uber Go Style Guide: https://github.com/uber-go/guide/blob/master/style.md.
2. `main` packages MUST live under `cmd/<name>/` and MUST contain only wiring; reusable logic MUST live under `internal/`.
3. Before any Go coding, review, debugging, or setup task, load the `golang-how-to` skill first; it routes to whichever other `golang-*` skills the task needs. The pack is installed by `npx skills add samber/cc-skills-golang -g --all` and flattened into `golang-*` skill names.
4. Zero speculative code: unrequested features, placeholder interfaces, kitchen-sink options, and Log/Metrics/Tracing abstraction layers MUST NOT be added.
5. Every change MUST pass `make pre-commit` (lint, `go test -race`, the coverage floor, and `dockerlint`) before it is proposed for merge.

## Test-driven development

1. Tests MUST be written before the implementation they cover: write the failing test, observe it fail for the intended reason, then implement until it passes. Implementation-first code MUST NOT be retrofitted with tests to satisfy a gate.
2. A test that cannot fail for the reason it claims (a missing assertion, an assertion on a value the test itself computed, a stub asserting on itself) MUST NOT be committed; it is a false pass.
3. Tests MUST live in an external test package (`package <pkg>_test`) and MUST exercise the package through its exported surface, unless the behavior under test is genuinely unexported.
4. Every exported identifier under `internal/` MUST have at least one test covering its contract, including its boundary inputs (empty, nil, zero, maximum).
5. Tests MUST be deterministic and independent: no shared mutable state, no reliance on execution order, no wall-clock or network dependence. `t.Parallel()` MUST be used where the test is safe to parallelize.
6. `make coverage-check` enforces a coverage floor on `./internal/...`. Coverage is a floor, not evidence of TDD, and MUST NOT be used to justify skipping rules 1 to 5.
7. Tests MUST be committed together with the code they cover; a change that adds behavior without tests is non-compliant.

## Architecture modeling (C4)

1. Architecture MUST be modeled with C4 diagrams held as Mermaid source under `docs/architecture/`, one file per level: `context.md` (L1), `container.md` (L2), `component.md` (L3). `docs/architecture/context.md` is the worked example for the format.
2. The level a change requires scales with its reach: L1 for a new external actor, system boundary, or third-party dependency; L2 for a new binary, package boundary, or datastore; L3 for the internals of a new package.
3. A diagram that contradicts the code is a defect of the same severity as a failing test. Diagrams MUST be updated in the same change as the code they describe.
4. Diagrams MUST be Mermaid source in Markdown. Rendered images (PNG, SVG) MUST NOT be committed.
5. Elements MUST use stable IDs matching the real identifiers (module, package, or service names). Decorative styling and custom colors MUST NOT be used, so the diagram renders consistently wherever Mermaid is supported.

## Toolchain and versions

1. The Go version in `go.mod` MUST match the newest version available in the local toolchain at the time of change.
2. GitHub Actions MUST be pinned to a released tag (`@vN`), never to a branch. When an action publishes no floating major tag, its full released version (`@vN.N.N`) MUST be pinned instead; `hadolint/hadolint-action` is one such action.
3. `golangci-lint` MUST run in its v2 configuration format (`.golangci.yml`, `version: "2"`).
4. Linter configuration MUST stay in `.golangci.yml`; per-line suppression MUST use a specific `//nolint:<linter> // <reason>` directive.
5. A workflow that uploads an artifact MUST set an explicit `retention-days` input (1 to 90, public-repository maximum) on that `actions/upload-artifact` step. The repository-level retention setting is not inherited by forks or by repositories generated from this template, so the per-step input is the only portable form.
6. Container images MUST be built by a multi-stage `Dockerfile` whose runtime stage is a distroless non-root image, and MUST be described by `compose.yaml`. `Dockerfile` changes MUST pass `make dockerlint`. hadolint's severity policy lives in `.hadolint.yaml`. Every dev tool installed by `make tools` MUST be pinned to an exact released version and MUST NOT use `@latest`. Each pin MUST be declared once: `golangci-lint` in `.golangci-lint-version`, which both the `Makefile` and the `lint` workflow read; `govulncheck` in `GOVULNCHECK_VERSION` and `hadolint` in `HADOLINT_VERSION` in the `Makefile`.
7. Dependencies MUST be updated by Dependabot in exactly three categories: `infra` (`docker`), `ci` (`github-actions`), and `code-lib` (`gomod`). Each category MUST run weekly on Monday with one catch-all group (`patterns: ["*"]`) and `open-pull-requests-limit: 1`, so a category never holds more than one open bump pull request. `rebase-strategy` MUST stay `auto`. The categories MUST be staggered one hour apart in UTC through the `time` input (`infra` 04:00, `ci` 05:00, `code-lib` 06:00), so their pull requests never compete for the same checks or review window. `time` only schedules when Dependabot checks for updates and opens or rebases a pull request; merging happens later, once the required checks pass.
8. Dependabot pull requests MUST be merged automatically by `.github/workflows/dependabot-automerge.yaml`, which enables auto-merge and lets the required status checks gate the merge. Auto-merge MUST NOT be treated as the gate itself: the checks it waits for MUST be the required status checks of the default-branch ruleset. Repository settings and rulesets are NOT inherited when a repository is created from this template, so a derived repository MUST set `allow_auto_merge` to `true` and re-create the ruleset before auto-merge takes effect.
9. Every merge to `main` MUST produce a tag and a GitHub release automatically, through `.github/workflows/release.yaml`. The bump defaults to `patch`; a Conventional Commit type in the pull request title escalates it (`feat:` to minor, `feat!:` or `BREAKING CHANGE:` to major). The release workflow MUST pin its actions to a released tag like every other workflow, and MUST run with `contents: write` scoped to that workflow alone.

## Artifact and document placement

1. Agent-generated plans MUST NOT be committed to the repository. They belong to the task's shared state folder (`plan-v<N>.md`, see Shared task state), which lives outside the repository and survives worktree removal.
2. Agent-generated documents that are not `AGENTS.md` or `README.md` MUST be placed under a `docs/` subdirectory.
3. Go source files MUST live in the layout defined under Implementation standards; the `docs/`-only rule above applies to documents, never to code.
4. Executable scripts MUST NOT be placed under `docs/`, which holds documents only. Git hooks live in the tracked `.githooks/` directory and are activated with `make install-pre-commit`, which points `core.hooksPath` at it; hooks MUST NOT be copied into `.git/hooks`, which is untracked and absent in a fresh clone.

### Scratch artifacts

1. Scratch artifacts MUST NOT be created anywhere inside the repository or its worktree. They MUST be created under a per-task subdirectory of the system temporary directory: `${TMPDIR:-/tmp}/<key>/`, where `<key>` is the shared task key defined under Shared task state. For work that creates no shared state folder (Q&A, one-off commands), the fallback key is `scratch-<YYYYMMDD>`.
2. Scratch artifacts are: throwaway probes and one-off scripts, captured command output and logs, downloaded toolchains, generated fixtures, and extracted archives.
3. The only paths an agent MAY create inside the repository are `bin/` (see Build artifact policy), documents under `docs/`, and the outputs of documented Makefile targets (see rule 5). A scratch artifact is never one of those. Plans are not documents under `docs/`: they are per-task working state and live in the shared state folder.
4. A tool that can only write inside the repository MUST be redirected to the scratch directory instead (for example `GOBIN`, `GOCACHE`, `--output`, or an absolute path argument). If it cannot be redirected, its in-repo path MUST be git-ignored in the same change and deleted before merge.
5. Cleanup MUST be verified, not assumed: before the task is reported complete, `git status --porcelain --ignored` MUST show nothing ignored beyond what the Makefile targets produce (`bin/` from `make build`/`make tools`, `coverage.out` from `make coverage`/`make coverage-check`), and the task's scratch directory MUST be removed.

## Build artifact policy

1. All compiled outputs MUST be written to `bin/`.
2. `bin/` artifacts MUST NOT be committed or pushed to the repository.

## Worktree, merge, and hygiene policy

1. All operations MUST be executed in a Git worktree.
2. Every work session MUST use the latest `main` branch as the base before implementation starts.
3. Every work session MUST check for residual unmerged or unfinished branches and MUST close or finish them when found.
4. Work is NOT complete until it is merged back into `main`.

## Change and versioning policy

1. Every change MUST bump the `Version` and refresh the `Updated-UTC` stamp in each document header it touches. Headers exist on `AGENTS.md`, `README.md`, `Makefile`, `.githooks/pre-commit`, and every file under `docs/architecture/`; a document without a header MUST NOT be created. Configuration, workflow, and source files (`.github/**`, `.golangci.yml`, `.hadolint.yaml`, `Dockerfile`, `compose.yaml`, and Go sources) are not documents and carry no header.
2. Version bumps MUST be semantic: patch for documentation or tooling fixes, minor for added targets, rules, or workflows, major for a layout change or a rule that invalidates existing contributor habits.
3. Every change MUST leave the tree reproducible: `make build` MUST succeed from a clean checkout with only the documented toolchain installed.
4. Superseded files MUST be deleted in the same change that replaces them; parallel old and new versions MUST NOT be left behind.

## Execution authority and ask boundaries

1. Default: implement in-scope work, local debugging, and reasonable defaults directly, without asking for pre-edit confirmation. Refactoring is limited to the current task's scope; incidental refactoring MUST NOT be performed.
2. Pause and confirm with a human ONLY in these cases: push, PR creation or merge, deleting remote work, or publishing externally; creating or modifying a data model or database schema; a high-cost, mutually exclusive architecture fork; writing to an external service.
3. Outside those cases, when information is missing, the spec is contradictory, or the work cannot be verified: take the conservative default, stop, and report. Never self-approve.
4. Headless runs have no interactive prompt. On a boundary, stop and emit `BLOCKED: <reason>` plus the authorization needed.

## Git and push gate

1. Commit messages, base-branch sync, and pushing MUST follow the `git-commit` skill.
2. NEVER commit or push without explicit human approval: implement and verify first, then wait for the instruction.

## Minimal diff

1. Every changed line MUST trace to the current task's request; incidental formatting, comment, and unrelated logic changes MUST NOT be included.
2. Orphaned code MUST be cleaned up only when this change invalidates it; pre-existing dead code MUST NOT be deleted on your own.

## Pre-completion exit criteria and reporting

Before confirmation, review the diff (staged and unstaged) and confirm all three checks:

1. No noise: no debug prints, temporary logs, unrelated formatting, or unused imports.
2. Defensive: nil/empty checks, error handling, and boundary conditions are present.
3. Consistency: the logic matches the task spec exactly.

Reporting contract:

- `CLEAN` / `ISSUES: <list>` is a machine verdict, not a chat signature. Every verification round MUST record `- <UTC> <command or check> → CLEAN|ISSUES: <list>` in `STATE.md` `## Verification`.
- Chat replies to a human lead with the verdict in prose and append `ISSUES: <list>` only when something failed; a trailing `CLEAN` MUST NOT be added.
- Delivery reports use three lines: Done / Not done / Next.

## Evidence discipline

1. Ran-this-session: a pass claim is valid only if the check ran in the current session and its output was observed; the claim names that command and matches its `## Verification` record.
2. Silence is not success: a zero-output command is confirmed by its exit code, an artifact, or a follow-up probe; state which one proved it.
3. Fact vs inference: factual claims cite `file:line` or command output; speculation carries the `inference:` marker and MUST NOT appear in a verdict line.
4. Unknown stays unknown: what cannot be verified is reported as `UNVERIFIED: <what>` plus the blocker; it MUST NOT be folded into a pass.
5. Negative claims need full coverage: "does not exist", "is unused", or "never happens" holds only if the search covered every place it could be.
6. Not-memory: a previous session's success, tool defaults, or documentation trust never verify current state.

## Agent-computer interface

1. One primary tool call per turn; narration minimal. Prefer fixing by configuration or data over editing source.
2. Locate first (grep with line numbers), then read one bounded window of at most 100 lines; a whole file MUST NOT be scrolled consecutively.
3. Command output is bounded at 100 lines; zero output is confirmed per Evidence discipline.
4. Run the file's lint/format gate before editing it; when the gate fails, the gate failure MUST be fixed first rather than pushing the edit through.
5. After three turns editing the same file without passing its gate, stop and emit `BLOCKED: aci edit-loop`.

## Shared task state

One state folder per task, shared by every agent, at `${AGENT_STATE_DIR:-$HOME/.local/state/agents}/<key>/`. The folder lives outside every repository, so it survives worktree removal and branch switches. The todo list and session files are session-only and are not shared state.

1. Key: a ticket ID when one exists; otherwise `T-<YYYYMMDD>-<kebab-short-name>`, which is also the branch name.
2. Files: `STATE.md` (current state, overwritten whole), `plan-v<N>.md` (plans, new versions only), `log.md` (append-only `<UTC> <agent> <event>` lines). Plans are written here and MUST NOT be committed to the repository.
3. Timing: read `STATE.md` and check it against git before starting; update it and append one `log.md` line before ending each round.
4. Executors change only `## Status`, `## Verification`, `## Gates`, `## Sessions`, and the header `status`/`updated`/`by` lines; `## Scope & constraints` is human-owned.
5. When `STATE.md` disagrees with git or the remote, the external system wins; correct `STATE.md` and append a `reconcile` line to `log.md`.
6. Closeout: move the folder to `_done/<YYYY>/<key>/`. Tokens, passwords, and credentials MUST NOT be stored there.

### STATE.md template

````markdown
# <key> - <title>
key: <key> | aliases: <old IDs or none> | ticket: <URL or none>
repos: <repo>, <repo>
status: <planned|in-progress|verified|delivered|blocked|done>
updated: <UTC> | by: <agent|human>

## Scope & constraints (human only)
## Repos & worktrees
- <repo> | branch <branch> | worktree <path> | base <branch>
## Status
Done: ...
Not done: ...
Next: ...
## Verification
- <UTC> <command or check> -> CLEAN|ISSUES: ...
## Gates (pending human decisions; BLOCKED reasons)
## Sessions
- <agent>: <session id> (<cwd>) | pr: <URL>
## Plan
current: plan-v<N>.md
````

