# Contributing

## To your own copy of this repository

Read [`docs/07-make-it-yours.md`](docs/07-make-it-yours.md) first, then:

1. Branch: `feature/<initials>-<short-description>`
2. Make the change
3. `./scripts/validate-structure.ps1`
4. Open a PR; fill in the template honestly, including the "not reviewable by eye" section
5. One reviewer, using [`review-checklist.md`](.github/standards/review-checklist.md)

### Conventional commits

`feat:` `fix:` `docs:` `chore:` `refactor:` `data:`

```
feat(sales): add returns to the gold star schema
docs(standards): clarify stage suffix rule for deployment pipelines
fix(ci): pin python to 3.11 so fabric-cicd resolves
```

### Two rules that keep this coherent

- **Index in the same commit.** Add a file, add its row to that folder's `README.md`. Not later.
- **Never change a `logicalId`, `type`, or item folder name**, and sync a workspace directory in one
  direction at a time. Editing item definitions is fine — see [`.github/copilot-instructions.md`](.github/copilot-instructions.md).

## To this reference repository

Issues and PRs welcome, particularly:

- **Corrections.** Fabric moves fast; if something here is out of date or wrong, that is the most
  valuable contribution. Please include the Microsoft Learn link.
- **Patterns that survived contact with reality.** A structure that worked at scale, or one that
  didn't and why.
- **Portability fixes.** Anything that works on GitHub but breaks on Azure DevOps is a bug here.

Less useful: adding more example projects, or vendoring Fabric platform documentation that
[`microsoft/skills-for-fabric`](https://github.com/microsoft/skills-for-fabric) already maintains.

### Before you open a PR

- `./scripts/validate-structure.ps1` passes
- No real customer names, tenant IDs, workspace GUIDs or internal URLs — the example is fictional
  and must stay that way
- New claims about platform behaviour link to Microsoft Learn

## Licence

Contributions are accepted under the [MIT Licence](LICENSE).
