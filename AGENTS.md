# AGENTS Contract

Doc-ID: AGENTS-GO-REPO
Version: 1.2.0
Updated-UTC: 2026-08-18T21:59:49Z

## Scope

This file defines mandatory repository rules for human and agent contributors.

## Implementation standards

1. Go directory structure and implementation MUST follow the Uber Go Style Guide: https://github.com/uber-go/guide/blob/master/style.md.
2. Development workflows MUST use `samber/cc-skills-golang` and `@opengsd/gsd-core` for planning, implementation, review, and verification.

## Artifact and document placement

1. Agent-generated plans MUST be stored under `docs/plans/`.
2. Any file created by agents that is not `AGENTS.md` or `README.md` MUST be placed under a `docs/` subdirectory.

## Build artifact policy

1. All compiled outputs MUST be written to `bin/`.
2. `bin/` artifacts MUST NOT be committed or pushed to the repository.

## Worktree, merge, and hygiene policy

1. All operations MUST be executed in a Git worktree.
2. Every work session MUST use the latest `main` branch as the base before implementation starts.
3. Every work session MUST check for residual unmerged or unfinished branches and MUST close or finish them when found.
4. Work is NOT complete until it is merged back into `main`.
5. Any change intended for merge MUST pass careful review, lint, pre-commit checks, and thorough testing before merge.
6. No residual garbage is allowed: temporary files, debug artifacts, and obsolete leftovers MUST be cleaned before merge.

## Compliance

Changes that violate any MUST rule above are non-compliant and MUST be corrected before merge.
