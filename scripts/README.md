# Scripts

Provider-neutral PowerShell 7. They run identically on a laptop, in GitHub Actions and in Azure
Pipelines — deliberately, because this repository has to work on both.

| Script | Does | Run it |
|---|---|---|
| [`validate-structure.ps1`](validate-structure.ps1) | Structure, `.platform`, link and secret checks | Locally before pushing; in CI on every PR |
| [`bootstrap-skills.ps1`](bootstrap-skills.ps1) | Sets up the Microsoft Fabric skills for your host | Once per machine |

## validate-structure.ps1

```powershell
./scripts/validate-structure.ps1
./scripts/validate-structure.ps1 -SkipLinks     # faster, for a tight loop
```

Checks, in order:

1. Every folder has a `README.md` index — Fabric-owned directories excluded, because a README inside
   one would show up as an unexpected change on the next sync
2. No unreplaced template placeholders outside `projects/_template/`
3. `.platform` files are valid JSON, complete, and consistent with their folder name
4. `logicalId` is a GUID and is unique within each workspace directory
5. Display names avoid the characters that force Fabric to fall back to a GUID folder name
6. Nothing but Fabric item folders sits inside a Git-connected workspace directory
7. Relative markdown links resolve
8. No obvious secrets

Exit code `0` pass, `1` fail. Warnings do not fail the build.

**Requires PowerShell 7.** Windows PowerShell 5.1 will not run it. `winget install Microsoft.PowerShell`,
or `brew install powershell`.

## bootstrap-skills.ps1

```powershell
./scripts/bootstrap-skills.ps1                     # print the plugin commands (recommended)
./scripts/bootstrap-skills.ps1 -Mode Vendor        # clone locally — no marketplace needed
./scripts/bootstrap-skills.ps1 -Mode Submodule -Ref v0.3.0   # pinned version
```

## Adding a script

Keep them dependency-free — PowerShell 7 built-ins only, no modules, no network in validation. The
moment a check needs a module, it stops running on someone's machine and starts being ignored.

## Related

- [`../.github/workflows/validate.yml`](../.github/workflows/validate.yml) — GitHub Actions caller
- [`../.azuredevops/pipelines/validate.yml`](../.azuredevops/pipelines/validate.yml) — Azure Pipelines caller
- [`../.github/standards/review-checklist.md`](../.github/standards/review-checklist.md) — what these checks automate
