# 06 — Azure DevOps Port

Everything here works on Azure DevOps. Fabric supports both providers natively, and this repository
was built so that the parts you actually maintain — standards, skills, agents, project structure —
are provider-neutral markdown.

## What changes, and what doesn't

| | GitHub | Azure DevOps | Change needed |
|---|---|---|---|
| `.github/copilot-instructions.md` | ✅ | ✅ | **none** |
| `.github/skills/`, `agents/`, `prompts/`, `standards/` | ✅ | ✅ | **none** |
| `AGENTS.md`, `CLAUDE.md` | ✅ | ✅ | **none** |
| `projects/**` | ✅ | ✅ | **none** |
| `scripts/*.ps1` | ✅ | ✅ | **none** |
| Fabric Git integration | ✅ | ✅ | pick the provider at connect time |
| CI | `.github/workflows/` | `.azuredevops/pipelines/` | both provided |
| PR template | `.github/pull_request_template.md` | `.azuredevops/pull_request_template.md` | both provided |
| Approvals | Environments + reviewers | Environments + checks | configured in the service |
| Secrets | Repo/environment secrets | Variable group → Key Vault | configured in the service |
| Branch protection | Branch protection rules | Branch policies | configured in the service |

Roughly 90% of this repository is byte-identical on both. The differences are all pipeline YAML and
service configuration — neither of which is where your intellectual property lives.

### Yes, keep the folder called `.github`

It looks GitHub-specific. It isn't, in the way that matters: AI coding tools key on that path.
VS Code Copilot reads `.github/copilot-instructions.md` from an Azure DevOps working copy exactly as
it does from a GitHub one, and `.github/prompts/*.prompt.md` are discovered the same way.

Renaming it to `.agent/` costs you automatic discovery in every tool and buys you nothing. If your
organisation genuinely cannot have a folder called `.github` in an Azure DevOps repo, keep it and add
a line to the README explaining why — that is cheaper than the alternative.

## Setup

### 1. Push the repository

```powershell
git remote add origin https://dev.azure.com/<org>/<project>/_git/<repo>
git push -u origin main
```

### 2. Validation pipeline

Pipelines → New pipeline → **Azure Repos Git** → your repo → **Existing Azure Pipelines YAML file**
→ `/.azuredevops/pipelines/validate.yml` → Save.

### 3. Branch policy

Repos → Branches → `main` → ⋯ → Branch policies:
- **Build validation** → the validate pipeline → **Required**
- **Minimum number of reviewers** → 1, and disallow self-approval
- **Check for linked work items** if that's how your organisation works

### 4. PR template

Azure DevOps looks for `.azuredevops/pull_request_template.md` automatically. Already present.

### 5. Deployment (branch-per-stage only)

1. **Service connection** — Project settings → Service connections → Azure Resource Manager →
   **Workload identity federation**. Name it `fabric-deploy`. No stored secret.
2. **Variable group** — Pipelines → Library → `fabric-deploy`, linked to Key Vault, holding
   `FABRIC_WORKSPACE_ID_TEST` and `FABRIC_WORKSPACE_ID_PROD`.
3. **Environments** — Pipelines → Environments → `fabric-test`, `fabric-prod` → Approvals and checks
   → add approvers on prod.
4. Create the pipeline from `/.azuredevops/pipelines/deploy.yml`.

### 6. Connect Fabric

Workspace settings → Git integration → **Azure DevOps** → organisation, project, repository, branch,
and the Git folder path. Same as [02](02-connect-a-workspace.md) from there.

### 7. Secret scanning

Azure DevOps has no exact equivalent to GitHub push protection. Options:
- **GitHub Advanced Security for Azure DevOps** (licensed) — the closest match
- A pre-commit hook plus the secret check already in `validate-structure.ps1`

The validation script is a backstop, not a control. It catches a mistake after it is committed; push
protection stops it being committed. Know which one you have.

## Azure DevOps-specific gotchas

| Thing | Detail |
|---|---|
| **Same tenant required** | The Azure DevOps repo must be in the same Entra tenant as the Fabric workspace. Cross-tenant is not supported. |
| **Provider APIs differ** | Microsoft explicitly recommends re-testing Git integration if you migrate between Azure DevOps and GitHub Enterprise — the underlying provider APIs have different limits. |
| **Wiki vs docs/** | Azure DevOps Wiki is tempting for standards. Resist splitting: keep standards next to the code they govern, and publish `docs/` as a **code wiki** if people want the Wiki reading experience. Two locations become two versions. |
| **Submodules** | If you vendored the Fabric skills as a submodule pointing at github.com, enable *Checkout submodules* on the job and give the build identity access to the public remote. Simpler: use `-Mode Vendor` in the pipeline instead. |
| **`pwsh` on agents** | Microsoft-hosted `ubuntu-latest` and `windows-latest` both have PowerShell 7. Self-hosted agents may not — install it, or the validation task fails at the `#Requires` line. |

## Related

- [`../.azuredevops/README.md`](../.azuredevops/README.md) — the folder itself
- [04 — CI/CD](04-ci-cd.md) — what the pipelines do
- [Fabric Git integration](https://learn.microsoft.com/fabric/cicd/git-integration/git-integration-process) — Microsoft Learn
