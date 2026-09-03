# 04 — CI/CD

Two pipelines, provided for both providers. They call the same PowerShell script, so behaviour does
not drift between GitHub and Azure DevOps.

| | GitHub | Azure DevOps |
|---|---|---|
| Validate | [`.github/workflows/validate.yml`](../.github/workflows/validate.yml) | [`.azuredevops/pipelines/validate.yml`](../.azuredevops/pipelines/validate.yml) |
| Deploy | [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml) | [`.azuredevops/pipelines/deploy.yml`](../.azuredevops/pipelines/deploy.yml) |

## Validate — runs on every PR

Two jobs:

1. **Structure** — `scripts/validate-structure.ps1`: README coverage, template placeholders,
   `.platform` integrity, `logicalId` uniqueness, display-name legality, workspace directory hygiene,
   markdown links, secrets.
2. **Fabric items** — parses every `.platform` and installs `fabric-cicd` so item definitions are
   checked with the same library used to deploy them.

**Make it required.** An advisory check is a check nobody reads.

- GitHub: Settings → Branches → protect `main` → require the `Validate` workflow
- Azure DevOps: Repos → Policies → `main` → Build validation → Required

### What it cannot catch

It reads files. It does not run notebooks, execute DAX, or know whether your numbers are right.
Correctness is the reviewer's job and the workspace's job.
[`review-checklist.md`](../.github/standards/review-checklist.md) splits the two explicitly.

## Deploy — manual, gated

Both deploy pipelines are **templates**. They will not run until you fill in the identity and
workspace variables. That is deliberate — a deploy pipeline that runs on a fresh clone is a deploy
pipeline pointed at someone else's tenant.

They use [`fabric-cicd`](https://microsoft.github.io/fabric-cicd/), Microsoft's Python library for
publishing Fabric items from a repository. It handles item ordering, dependencies and
parameterisation, which is why this repo doesn't hand-roll REST calls.

### Only needed for branch-per-stage

If your project promotes with **Fabric deployment pipelines** (the default here), promotion happens
inside Fabric and these workflows are unnecessary. Keep the validate pipeline; delete the deploy one
rather than leaving a disabled workflow around to confuse people.

### Authentication — no stored secrets

| | Mechanism |
|---|---|
| GitHub | OIDC federated credential → `azure/login@v2` with `id-token: write` |
| Azure DevOps | Workload identity federation service connection → `AzureCLI@2` with `addSpnToEnvironment` |

Both end up with `DefaultAzureCredential` working, and neither stores a client secret anywhere.

The service principal needs the tenant setting **"Service principals can use Fabric APIs"** enabled
for a group containing it. Check this before debugging your YAML — the failure looks like an auth bug.

### Approvals

Approval lives in the **environment**, not in YAML, so it cannot be edited away in a PR by the person
who wants to deploy.

- GitHub: Settings → Environments → `fabric-prod` → required reviewers
- Azure DevOps: Pipelines → Environments → `fabric-prod` → Approvals and checks

### Parameterisation

Stage-specific values — workspace IDs, connection strings, lakehouse GUIDs — go in `fabric-cicd`'s
`parameter.yml`, never in item definitions. One definition, many environments. The moment content
differs per branch, you no longer have a promotion process; you have three codebases.

## After every deployment

The list that stops the "why is test empty" conversation:

1. **Run the load in the target.** Metadata moved; data did not.
2. **Recreate Spark views** — they don't travel.
3. **Check shortcuts** — internal ones auto-remap, external ones need parameterising.
4. **Check OneLake data access role names** match across stages, or Direct Lake security degrades quietly.
5. **Verify row counts** before anyone quotes a number from the target stage.

Automated as the `/release-readiness` prompt.

## Related

- [`../scripts/README.md`](../scripts/README.md) — what validation actually checks
- [`../.github/agents/release-manager.md`](../.github/agents/release-manager.md)
- [06 — Azure DevOps port](06-azure-devops-port.md)
- [`fabric-cicd` documentation](https://microsoft.github.io/fabric-cicd/)
