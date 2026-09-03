# Fabric Project Structure

A reference repository layout for teams building on **Microsoft Fabric** with **Git integration** and **AI coding agents**.

It answers one question: *if we put our Fabric estate in Git, what does the repo actually look like?*

The shape is deliberately simple:

```
one shared core  +  many workspace folders
```

The **shared core** (`.github/`) holds everything that is true for the whole team — standards, agent skills, agents, prompts. The **workspace folders** (`projects/<project>/workspaces/<workspace>/`) each map 1:1 onto a Fabric workspace via Git integration.

> **Works on GitHub and Azure DevOps.** Fabric supports both providers, and so does this layout. Nothing in the shared core is GitHub-specific — see [`docs/06-azure-devops-port.md`](docs/06-azure-devops-port.md).

---

## The layout

```
fabric-project-structure/
│
├── .github/                        ← SHARED CORE — one team, one set of rules
│   ├── copilot-instructions.md     ← what every agent reads first
│   ├── standards/                  ← naming, branching, review, security, glossary
│   ├── skills/                     ← YOUR functional skills (technical basics come from Microsoft)
│   ├── agents/                     ← role definitions: data engineer, report author, release manager
│   ├── prompts/                    ← reusable workflows invoked as /name or #name
│   └── workflows/                  ← GitHub Actions CI
│
├── .azuredevops/                   ← the same CI, as Azure Pipelines
│
├── projects/                       ← PER PROJECT
│   ├── _template/                  ← copy this to start a new project
│   └── sales-analytics/            ← worked example
│       ├── README.md
│       ├── project-context.md      ← project-specific guidance agents read
│       ├── decisions/              ← ADRs — why this project is built the way it is
│       └── workspaces/             ← PER WORKSPACE
│           └── ws-sales-analytics-dev/   ← ★ this folder is Git-connected to a Fabric workspace
│
├── docs/                           ← how to run this thing
└── scripts/                        ← provider-neutral validation
```

## Why project → workspace, and not just workspace

Fabric Git integration connects **one workspace to one branch and one directory**. A repository can serve many workspaces as long as each gets its own directory. So a flat `workspaces/` folder would work.

We add the `projects/` level anyway, because the directory is the *only* thing Fabric cares about — everything else in the repo is for humans and agents. Grouping by project gives you the place to put the things Fabric has no concept of:

| Lives at project level | Why it can't live at workspace level |
|---|---|
| `project-context.md` | One project usually spans dev/test/prod workspaces — the business context is the same for all of them |
| `decisions/` (ADRs) | Architecture decisions outlive individual workspaces |
| Ownership, stakeholders | A workspace is infrastructure; a project has people |

If you only ever have one project, collapse the level. The pattern degrades gracefully; the reverse — retrofitting a grouping level onto 40 flat workspace folders — does not.

## Two layers of agent knowledge

This is the part most teams get wrong. Agent knowledge splits cleanly in two, and only one half is yours to write.

| Layer | What it knows | Who maintains it | Where it comes from |
|---|---|---|---|
| **Technical basics** | How Fabric works — Spark, Warehouse, Direct Lake, pipelines, REST APIs, Power BI modelling | Microsoft | [`microsoft/skills-for-fabric`](https://github.com/microsoft/skills-for-fabric) — installed, not copied |
| **Functional guidance** | How *your company* works — your domain language, your naming rules, your review gates, your project context | You | `.github/skills/`, `.github/standards/`, `projects/*/project-context.md` |

Do not fork the technical layer. It ships new Fabric capability continuously and you will fall behind within a quarter. Install it and spend your effort on the half nobody else can write for you.

Setup: [`docs/05-agentic-development.md`](docs/05-agentic-development.md) · one-command bootstrap: `scripts/bootstrap-skills.ps1`

## Start here

| I want to… | Read |
|---|---|
| Understand the idea in 5 minutes | This page |
| Clone it and get running | [`docs/01-getting-started.md`](docs/01-getting-started.md) |
| Connect my first Fabric workspace | [`docs/02-connect-a-workspace.md`](docs/02-connect-a-workspace.md) |
| Decide how changes reach production | [`docs/03-branching-and-promotion.md`](docs/03-branching-and-promotion.md) |
| Set up build/release automation | [`docs/04-ci-cd.md`](docs/04-ci-cd.md) |
| Wire up Copilot and Fabric skills | [`docs/05-agentic-development.md`](docs/05-agentic-development.md) |
| Run this on Azure DevOps instead | [`docs/06-azure-devops-port.md`](docs/06-azure-devops-port.md) |
| Adapt it to my organisation | [`docs/07-make-it-yours.md`](docs/07-make-it-yours.md) |

## What this repository is not

- **Not a Fabric deployment tool.** Promotion between stages is done by Fabric deployment pipelines or `fabric-cicd`. This repo shows where they plug in.
- **Not a substitute for reading the docs.** Every non-obvious claim links to Microsoft Learn.
- **Not prescriptive about your naming.** [`.github/standards/naming-conventions.md`](.github/standards/naming-conventions.md) is a starting point with the reasoning attached. Change it — but change it once, in one place.

## Licence

[MIT](LICENSE). Copy it, fork it, rename it, strip the example project, ship it internally. Attribution appreciated, not required.
