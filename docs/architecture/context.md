# C4 Level 1: System Context

Doc-ID: ARCH-CONTEXT-GO-REPO
Version: 1.0.0
Updated-UTC: 2026-10-16T11:37:00Z

Who uses `go-repo` and which external systems it depends on. This file is the worked example for the format required by `AGENTS.md` under Architecture modeling (C4).

```mermaid
C4Context
    title System Context diagram for go-repo

    Person(contributor, "Contributor", "Clones the template and runs the Makefile targets")
    System(repo, "go-repo", "Public Go repository template with lint, test, and security gates")

    System_Ext(github, "GitHub", "Hosts the repository and runs the CI workflows")
    System_Ext(goproxy, "Go module proxy", "Serves module downloads for builds and CI")
    System_Ext(dependabot, "Dependabot", "Opens weekly dependency update pull requests")

    Rel(contributor, repo, "Clones, builds, tests, lints")
    Rel(repo, github, "Runs workflows on push and pull request")
    Rel(github, goproxy, "Downloads modules")
    Rel(dependabot, repo, "Opens pull requests against")
```

## Notes

- `repo` is the system boundary: everything inside is this repository, everything else is external.
- There is no runtime service. The template is consumed at build and CI time only.
