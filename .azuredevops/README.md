# Azure DevOps

Everything in this repository works on Azure DevOps. This folder holds the pieces that have a
different shape there.

| GitHub | Azure DevOps | In this repo |
|---|---|---|
| `.github/workflows/validate.yml` | `.azuredevops/pipelines/validate.yml` | Both present |
| `.github/workflows/deploy.yml` | `.azuredevops/pipelines/deploy.yml` | Both present |
| `.github/pull_request_template.md` | `.azuredevops/pull_request_template.md` | Both present |
| Environments + required reviewers | Environments + approval checks | Configured in the service, not in the repo |
| Repository variables / secrets | Variable groups linked to Key Vault | Configured in the service |

## What does **not** change

- `.github/copilot-instructions.md`, `skills/`, `agents/`, `prompts/`, `standards/`
- `AGENTS.md`, `CLAUDE.md`
- `projects/**` — the whole project and workspace layout
- `scripts/*.ps1`

The `.github` folder name is a convention that AI coding tools key on, not a GitHub dependency.
VS Code Copilot reads `.github/copilot-instructions.md` from an Azure DevOps working copy exactly as
it does from a GitHub one. Leave the folder where it is.

## Setting it up

1. **Pipelines** → New pipeline → Azure Repos Git → Existing YAML file →
   `/.azuredevops/pipelines/validate.yml`
2. **Branch policies** on `main` → Build validation → add the validate pipeline, set it Required
3. **Pipelines → Environments** → create `fabric-test` and `fabric-prod`, add approval checks
4. **Library** → variable group `fabric-deploy`, linked to Key Vault, holding the service connection
   details and per-stage workspace IDs
5. **Project settings → Repositories → Policies** → enable the PR template

Full walkthrough: [`../docs/06-azure-devops-port.md`](../docs/06-azure-devops-port.md)

## Two things that catch people out

- **Fabric Git integration for Azure DevOps requires the repo to be in the same Entra tenant** as the
  Fabric workspace. Cross-tenant is not supported.
- **Azure DevOps and GitHub have different Git provider API limits.** If you ever migrate between
  them, re-test Git integration rather than assuming it behaves identically —
  [Microsoft says so explicitly](https://learn.microsoft.com/fabric/cicd/git-integration/git-integration-process).

## Related

- [`../docs/06-azure-devops-port.md`](../docs/06-azure-devops-port.md) — the full port guide
- [`../docs/04-ci-cd.md`](../docs/04-ci-cd.md) — what the pipelines do
