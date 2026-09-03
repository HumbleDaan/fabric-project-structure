# Security and Access

Two questions: who can change what, and where do secrets live.

## Workspace roles

Fabric workspace roles are the real permission boundary — Git access does not grant Fabric access,
and vice versa. Keep them deliberately narrow.

| Stage | Admin | Member | Contributor | Viewer |
|---|---|---|---|---|
| `*-dev` | Platform team | Lead engineer | Everyone on the project | — |
| `*-test` | Platform team | Lead engineer | — | Testers, business reviewers |
| `*-prod` | Platform team (2 people) | Service principal used by the release pipeline | **nobody** | Consumers via an app, not the workspace |

The important line is the empty one: **no humans have Contributor on production.** If someone needs
to change prod, they change dev and ship it. That is the whole point of the pipeline.

Assign roles to **Entra groups**, never to individuals. An individual assignment is a leaver-process
problem waiting to happen.

## Git access

- Git permissions and Fabric permissions are separate systems. A user needs **both** to sync.
- To connect a workspace to Git, the user needs workspace Admin *and* write access to the repo.
- The Git connection is made **by a user identity**, and Fabric records who connected it. If that
  person leaves, someone must reconnect. Consider a shared service account for long-lived
  connections in test/prod. ([Reference](https://learn.microsoft.com/fabric/cicd/git-integration/git-integration-process))

## Where secrets live

| Kind | Goes in | Never in |
|---|---|---|
| Service principal secret / certificate | Azure Key Vault, referenced by the pipeline | The repo, a notebook, a `.env` committed by accident |
| Storage keys, SAS tokens | Key Vault or a Fabric connection | Notebook cells, pipeline JSON |
| Stage-specific IDs (workspace, capacity, lakehouse) | `parameter.yml` / Variable Library | Item definitions |
| Personal tokens | Nowhere. Use a service principal. | Anywhere |

Fabric notebooks should read secrets through `notebookutils.credentials.getSecret()` against Key
Vault, not through a hard-coded value or a widget default.

`.gitignore` already blocks `*.env`, `*.pem`, `*.key`, `*.pfx` and `local.settings.json`. That is a
safety net, not a control — enable **secret scanning + push protection** on the repository (GitHub
Advanced Security, or the equivalent in Azure DevOps) so a mistake is blocked at push time.

## Service principals

Use one per stage, with the smallest role that works:

| Principal | Role | Used by |
|---|---|---|
| `sp-fabric-cicd-dev` | Contributor on `*-dev` | CI validation |
| `sp-fabric-cicd-prod` | Member on `*-prod` | Release pipeline only |

Service principal support for Fabric APIs requires the tenant setting **"Service principals can use
Fabric APIs"** to be enabled for a security group containing the principal. Ask your Fabric admin
before assuming it works. ([Reference](https://learn.microsoft.com/fabric/admin/tenant-settings-index))

## Data access

Workspace roles control *items*. They are not row-level security. If different users must see
different rows or columns, that is:

- **OneLake data access roles** on the lakehouse, and/or
- **RLS/OLS** in the semantic model.

Note for Direct Lake: OneLake data access **role definitions** promote inconsistently across stages
today. Verify that role names match exactly in every stage, or security silently degrades after a
deployment. Check the current status before relying on it.

## Related

- [`branching-and-workspaces.md`](branching-and-workspaces.md) — which workspaces exist per stage
- [`review-checklist.md`](review-checklist.md) — the secret-scanning line in review
- [`../../docs/04-ci-cd.md`](../../docs/04-ci-cd.md) — where the principals are used
