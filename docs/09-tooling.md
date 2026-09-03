# 09 — Tooling

What to install, what to avoid, and what will quietly corrupt your Git integration if you let it.

> **Verified 2026-09-03.** Versions and preview/GA status move fast. Re-check anything marked
> *preview* before you rely on it.

## The short list

| Tool | Install | Licence | Use it for |
|---|---|---|---|
| **Fabric CLI** (`fab`) | `pip install ms-fabric-cli` | MIT | Everything interactive and scripted: browse, CRUD, export/import, jobs, ACLs, REST passthrough |
| **fabric-cicd** | `pip install fabric-cicd` | MIT | Publishing a repo directory into a workspace. Already wired into this repo's deploy pipelines |
| **SqlPackage** | `dotnet tool install -g microsoft.sqlpackage` | Free, proprietary | Warehouse / SQL database projects (`.sqlproj` → `.dacpac` → deploy) |
| **Tabular Editor 2 CLI** | `TabularEditor.exe` | MIT | Best-practice analysis of semantic models in CI |
| **PBIR-Utils** | `pip install pbir-utils` | MIT | Batch edits and dependency extraction across PBIR report files |

All five are headless-capable. Details and caveats below.

## Fabric CLI (`fab`) — the one CLI

**GA since May 2025** ([announcement](https://community.fabric.microsoft.com/blog/fbc_fabricupdatesblogs/fabric-cli-explore-and-automate-microsoft-fabric-from-your-terminal-generally-av/5172744)),
open-sourced September 2025. Docs: [microsoft.github.io/fabric-cli](https://microsoft.github.io/fabric-cli/) ·
Repo: [microsoft/fabric-cli](https://github.com/microsoft/fabric-cli) ·
Learn: [Fabric command line interface](https://learn.microsoft.com/rest/api/fabric/articles/fabric-command-line-interface)

It presents Fabric as a filesystem. Command groups: `fs`, `table`, `job`, `acls`, `label`, `auth`,
`config`, `api`.

### Auth for CI

| Mode | Command | Headless |
|---|---|---|
| Interactive | `fab auth login` | ❌ |
| SPN + secret | `fab auth login -u <client_id> -p <secret> --tenant <tid>` | ✅ |
| SPN + certificate | `fab auth login -u <id> --certificate cert.pem --tenant <tid>` | ✅ |
| **SPN + federated token (OIDC)** | `fab auth login -u <id> --federated-token <token> --tenant <tid>` | ✅ **preferred** |
| Managed identity | `fab auth login --identity` | ✅ (validated on Azure VMs only) |

Use the federated-token path with GitHub Actions' `id-token: write` or an Azure DevOps
workload-identity service connection — same no-stored-secret posture as this repo's deploy pipelines.

Prerequisite: the **"Service principals can use Fabric APIs"** tenant setting, enabled for a group
containing the principal. The failure mode without it looks like a bug in your YAML.

### There is no `fab git` command group

This surprises people. Git integration is driven through the `fab api` passthrough against the
[Git REST APIs](https://learn.microsoft.com/rest/api/fabric/core/git) —
`Connect`, `Disconnect`, `Initialize connection`, `Get status`, `Commit to Git`, `Update from Git`.

```bash
fab api "workspaces/${WORKSPACE_ID}/git/status" --show_headers
```

Three things that will catch you, all documented in Microsoft's own
`git-integration-operations-cli` skill:

1. **`commitToGit`, `updateFromGit` and even `git/status` can return HTTP 202.** Poll
   `fab api operations/{id}` using `x-ms-operation-id` from `--show_headers` until `Succeeded`, then
   confirm `workspaceHead == remoteCommitHash`.
2. **`updateFromGit` needs the current `workspaceHead`.** A stale value gives `400 WorkspaceHeadMismatch`.
   Always read `git/status` first.
3. **The workspace must be assigned to a capacity**, and only one Git operation runs per workspace at
   a time. Connect/disconnect need Admin; commit/update need Contributor.

### ⚠️ `fab export` output is not Git-integration output

> "`fab export` exports one item at a time and **does not include logical IDs**."
> — [fab deploy docs](https://microsoft.github.io/fabric-cli/commands/fs/deploy/)

Git integration writes a `.platform` file containing `logicalId`. `fab export` does not, and it drops
sensitivity labels. **Never commit `fab export` output into a Git-connected workspace directory** —
Fabric cannot correlate the items. Keep exports in a separate, non-synced folder.

### ⚠️ `fab deploy` unpublishes by default

`fab deploy` (v1.5+) runs `fabric-cicd` underneath. Publish *and* unpublish are both on unless you
explicitly skip unpublish per environment — so an incomplete source directory **deletes** items in the
target workspace. Know this before you point it at anything that matters.

## The workload "CLIs" are not CLIs

If you have seen `spark-cli`, `sqldw-cli`, `eventhouse-cli`, `activator-cli`,
`git-integration-operations-cli` and assumed they were installable tools — they are not.

They are **agent skills inside [`microsoft/skills-for-fabric`](https://github.com/microsoft/skills-for-fabric)**:
markdown instruction files that tell an AI agent which REST endpoints to call, usually via `fab api`.
There are no binaries, no PyPI packages, no `--help`. The `-cli` suffix means "skill for a CLI/agent
environment", as opposed to the MCP-server-backed skills.

This is good news: **you already get them** from the bundle this repo tells you to install.

```
/plugin marketplace add microsoft/skills-for-fabric
/plugin install fabric-skills@fabric-collection
/plugin install powerbi-authoring@fabric-collection
```

The `fabric-skills` bundle ships 22 skills, including the twelve workload ones, plus
`deployment-pipelines-authoring-cli`, `git-integration-operations-cli`, four migration skills
(Databricks, Synapse, HDInsight, pipelines), and four agents.

Two notes:
- Older bundle names (`skills-for-fabric`, `fabric-authoring`, `fabric-consumption`,
  `fabric-operations`) still resolve but are **deprecated aliases**. Use `fabric-skills`.
- `git-integration-operations-cli` declares `maturity: experimental` in its own frontmatter. Read it
  for the endpoint patterns; don't treat it as a supported product.

This is the same install-don't-copy argument as [`../.github/skills/README.md`](../.github/skills/README.md),
and it is why that argument matters: the workload coverage grows every month.

## Report tooling — read the licence first

### `pbir-cli` — we do not recommend it

It exists ([PyPI](https://pypi.org/project/pbir-cli)), authored by Kurt Buhler and Maxim Anatsko. It
is a capable-looking tool from credible people. But for a repository you hand to a customer, three
things disqualify it:

| Issue | Detail |
|---|---|
| **Non-commercial licence** | "use the Software for **non-commercial purposes only**... Commercial purposes include... using the Software to provide paid consulting or development services." Derivative works "expressly forbidden." |
| **Closed source** | Binary wheels only. The declared repo `github.com/data-goblin/pbir-cli` returns 404. |
| **No Linux wheel** | Windows x64 and macOS arm64 only — rules out most CI runners. Alpha maturity. |

If you are doing Fabric work commercially — which, if you are reading this, you probably are — you
would need written permission from the authors. That is a materially different proposition from
every other tool on this page.

### Use PBIR-Utils instead

[`pbir-utils`](https://github.com/akhilannan/pbir-utils) — MIT, actively maintained, pure Python so
it runs anywhere. Batch metadata edits across PBIR projects, report wireframes, dependency
extraction. Community-maintained rather than Microsoft, but openly auditable.

For semantic models rather than reports, Microsoft's
[`powerbi-modeling-mcp`](https://github.com/microsoft/skills-for-fabric) ships in the
`powerbi-authoring` bundle — an MCP server for agent-driven model authoring, not a CLI.

## Semantic model tooling

| Tool | CI-suitable | Licence |
|---|---|---|
| **Tabular Editor 2** (`TabularEditor.exe`) | ✅ **the production option** | MIT, free |
| Tabular Editor 3 | ❌ **has no CLI at all** | Commercial |
| `te` (new cross-platform CLI) | ❌ **preview build expires 2026-09-30** | Free during preview |

Running TE2 in CI [does not require a TE3 licence](https://docs.tabulareditor.com/en/features/Command-line-Options.html).
Use `-A`/`-AX` for best-practice analysis, `-V` for Azure DevOps annotations, `-G` for GitHub.
Quirk: it's a WinForms app, so invoke it as `start /wait TabularEditor ...` and use Windows runners.

**Run linters in check-only mode.** TE2's `-F`/`-TMDL` output and `te bpa run --fix` rewrite model
files. CI that auto-fixes produces commits that fight the ones Fabric produces. Fail the build; let a
human fix it locally.

## Warehouse and SQL database projects

[SqlPackage](https://learn.microsoft.com/sql/tools/sqlpackage/sqlpackage-download) —
`dotnet tool install -g microsoft.sqlpackage`. Free, cross-platform, headless via
`/at:<token>` or an AAD service principal connection string.

This is the tooling behind the Git-first warehouse workflow: edit the database project locally, build
it, push, and let Git integration sync it into the workspace.

- **Fabric Warehouse support is [preview](https://learn.microsoft.com/fabric/data-warehouse/develop-warehouse-project)**;
  Fabric SQL database support has no preview banner.
- Only **SDK-style** projects (`Microsoft.Build.Sql`) are supported.
- Warehouse server format is `<id>.datawarehouse.fabric.microsoft.com` — **not** the SQL analytics
  endpoint. Easy hour to lose.
- Two flags to set deliberately: `BlockOnPossibleDataLoss` (always `True` in production) and
  `DropObjectsNotInSource` (can delete objects and data).

## semantic-link-labs

[`pip install semantic-link-labs`](https://github.com/microsoft/semantic-link-labs) — Microsoft, MIT,
but **alpha** and explicitly "designed for use in Microsoft Fabric notebooks."

It ships a `ServicePrincipalTokenProvider`, so the admin subpackage, Azure API wrappers and
`connect_semantic_model` do work outside a notebook. Spark- and lakehouse-dependent functions do not.
Microsoft has published no statement either way, so verify per function rather than assuming.

## Rules that apply to every tool here

1. **Nothing rewrites `.platform`.** If you add a JSON formatter, a prettifier, or a repo-wide lint
   fixer, **exclude `.platform`**. `logicalId` is "essential not to change in any way" and `type` is
   case-sensitive. This is the single highest-consequence tooling mistake available.
2. **Item directory names are load-bearing.** No tool should rename them. Renaming breaks name sync
   and silently invalidates dependency paths in other items.
3. **Keep exports out of synced directories.** Anything produced by `fab export`, `pbi-tools`, or a
   Desktop save-as goes in its own folder.
4. **Expect format drift in reports.** Git integration exports PBIR-legacy (`report.json`) unless a
   report was *imported* as PBIR — so one repo can hold both formats, and PBIX↔PBIP conversion is
   Desktop-only and [not scriptable](https://learn.microsoft.com/power-bi/developer/projects/projects-overview).
   Report tooling must handle both.
5. **Pin your line endings.** Power BI Desktop writes CRLF; Fabric writes LF. This repo's
   `.gitattributes` sets `eol=lf` for exactly this reason. Files must be UTF-8 without BOM, and
   Windows still has a 260-character path limit.

## Still preview — check before relying on

- PBIP and PBIR report formats (PBIR GA was targeted at Q3 2026; not announced as of Aug 2026)
- Fabric Warehouse database projects
- Azure DevOps Pipelines extension for Fabric
- Fabric Git integration for Warehouse

## Related

- [04 — CI/CD](04-ci-cd.md) — where these run in the pipelines
- [05 — Agentic development](05-agentic-development.md) — installing the Fabric skills
- [06 — Azure DevOps port](06-azure-devops-port.md) — provider differences
- [`../.github/skills/README.md`](../.github/skills/README.md) — install vs. author
