# C4 Level 2: Container

Doc-ID: ARCH-CONTAINER-GO-REPO
Version: 1.1.0
Updated-UTC: 2026-10-16T12:52:00Z

The runnable and buildable units inside `go-repo`. A "container" in C4 terms is anything that executes or is built: the binary, the library package, the tool binaries, and the CI pipelines.

```mermaid
C4Container
    title Container diagram for go-repo

    Person(contributor, "Contributor", "Runs make targets locally")

    Container_Boundary(repo, "go-repo") {
        Container(cmd, "cmd/dummy", "Go binary", "Entry point; wiring only, calls the library")
        Container(internal, "internal/greet", "Go package", "Reusable greeting logic")
        Container(makefile, "Makefile", "Make", "Build, test, lint, coverage, and vuln entry points")
        Container(toolbin, "bin/", "Go and static binaries", "Pinned golangci-lint, govulncheck, and hadolint, git-ignored")
        Container(dockerfile, "Dockerfile", "Container image", "Multi-stage build producing a distroless non-root image")
    }

    System_Ext(actions, "GitHub Actions", "CI: lint, dockerlint, test, vuln, and CodeQL jobs")

    Rel(contributor, makefile, "Runs targets")
    Rel(makefile, cmd, "Builds via make build")
    Rel(makefile, internal, "Tests via make test and make coverage-check")
    Rel(makefile, toolbin, "Installs and invokes pinned tools")
    Rel(cmd, internal, "Imports greet")
    Rel(actions, makefile, "Runs make targets on push and pull request")
    Rel(dockerfile, cmd, "Builds and packages the dummy binary")
    Rel(makefile, dockerfile, "Lints via make dockerlint and builds via docker compose")
```

## Notes

- `bin/` is a container because it holds executables, but it is git-ignored and MUST NOT be committed.
- `internal/greet` is the only package holding reusable logic; `cmd/dummy` MUST stay wiring-only.
