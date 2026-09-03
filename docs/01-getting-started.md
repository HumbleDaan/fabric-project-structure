# 01 — Getting Started

Fifteen minutes from clone to a validated repository with working agents.

## Prerequisites

| | Why |
|---|---|
| **PowerShell 7+** | The validation script. `winget install Microsoft.PowerShell` or `brew install powershell` |
| **Git** | Obviously |
| **A Fabric workspace on capacity** | Git integration is unavailable on Pro-only workspaces |
| **VS Code + GitHub Copilot**, or **Copilot CLI** | Optional, but the agent layer is half the point |
| **Azure CLI** | Only if you want live MCP access to Fabric |

## 1. Get a copy

```powershell
git clone https://github.com/HumbleDaan/fabric-project-structure.git my-fabric-repo
cd my-fabric-repo
Remove-Item .git -Recurse -Force
git init -b main
```

Removing `.git` is deliberate — you want your own history, not this repository's.

## 2. Check it runs

```powershell
./scripts/validate-structure.ps1
```

Expect `Structure validation PASSED.` If not, you have a PowerShell version problem — this needs 7,
not Windows PowerShell 5.1.

## 3. Install the Fabric skills

```powershell
./scripts/bootstrap-skills.ps1
```

It prints the commands for your host. In Copilot CLI:

```
/plugin marketplace add microsoft/skills-for-fabric
/plugin install fabric-skills@fabric-collection
```

This is the technical layer — how Fabric works. Detail in [05](05-agentic-development.md).

## 4. Make the standards yours

Three files, twenty minutes, before anyone creates anything:

| File | Decide |
|---|---|
| [`../.github/standards/naming-conventions.md`](../.github/standards/naming-conventions.md) | Your org tag, your domain names, your item prefixes |
| [`../.github/standards/branching-and-workspaces.md`](../.github/standards/branching-and-workspaces.md) | Deployment pipelines or branch per stage — see [03](03-branching-and-promotion.md) |
| [`../.github/standards/glossary.md`](../.github/standards/glossary.md) | Replace the example business terms with five real ones |

Every rule has its reasoning attached so you can tell which parts are load-bearing. Change them now,
while nothing depends on them.

## 5. Create your first project

```powershell
Copy-Item projects/_template projects/my-project -Recurse
```

Fill in `README.md` and `project-context.md` — validation fails while placeholder markers remain.

Then delete the example:

```powershell
Remove-Item projects/sales-analytics -Recurse -Force
```

Keep it for a week if it is useful as a reference. Delete it before anyone mistakes Contoso for a
real customer.

## 6. Connect a workspace

[02 — Connect a workspace](02-connect-a-workspace.md), or run the `/new-workspace` prompt and let an
agent do the repo side.

## 7. Turn on the guard rails

- **Branch protection on `main`** — require the validate workflow, require one review
- **Secret scanning + push protection** — GitHub Advanced Security, or the Azure DevOps equivalent
- Azure DevOps: [06](06-azure-devops-port.md)

## Checklist

- [ ] Validation passes
- [ ] Fabric skills installed
- [ ] Naming conventions reflect your organisation
- [ ] Promotion pattern chosen and written into a project ADR
- [ ] Glossary has real terms
- [ ] Example project deleted
- [ ] One workspace connected and syncing
- [ ] Branch protection on

## Related

- [02 — Connect a workspace](02-connect-a-workspace.md)
- [07 — Make it yours](07-make-it-yours.md)
