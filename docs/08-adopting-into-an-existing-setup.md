# 08 — Adopting This Into an Existing Setup

Most teams reading this already have something. Workspaces exist, some are already Git-connected,
there are repos with history, and there is a way of working — usually an undocumented one that
varies by person.

This doc is about that case. The short version: **the structure is the cheap part, and it is not
what is broken.**

## Three decisions, not one

The most common mistake is treating adoption as a single yes/no. It is three separable decisions with
very different costs, and you can take them in any order — or stop after the first.

| # | Decision | Touches Fabric? | Risk | Realistic effort |
|---|---|---|---|---|
| 1 | Adopt the **shared core** (`.github/`) | **No** | Very low | Days |
| 2 | Adopt the **directory layout** (`projects/*/workspaces/*/`) | **Yes** — reconnect required | Moderate | Half a day per workspace, after a pilot |
| 3 | Change the **repo topology** (consolidate or split) | Indirectly | Mostly political | Weeks, mostly discussion |

Decision 1 carries most of the value and almost none of the risk. If you only ever do decision 1,
you have still fixed the thing that was actually wrong.

## Why "disjointed" usually isn't a structure problem

"Everyone does it differently" is rarely caused by folder layout. Match the symptom to the decision
that fixes it:

| What you actually observe | Root cause | Fixed by |
|---|---|---|
| Naming is inconsistent across workspaces | No agreed standard, or one nobody can find | **1** |
| Reviews catch different things depending on the reviewer | No shared checklist | **1** |
| Copilot gives generic answers, or confidently wrong Fabric answers | No repo context, no Fabric skills installed | **1** |
| Nobody knows why something was built this way | No ADRs | **1** |
| New joiners take months to become useful | Knowledge is in people, not in the repo | **1** |
| Two teams can't tell whose items are whose in one repo | Wrong permission boundary | **3** |
| Nobody can find which repo holds which workspace | No convention, or too many repos | **2** and **3** |
| The same standards file exists in five repos, all different | No install mechanism for shared content | **3** |

Six of the eight are decision 1. That is the case for starting there regardless of how the repos
are laid out today.

## Decision 1 — take the shared core

This is a copy-in. Nothing under a Git-connected workspace directory changes, so there is **no Fabric
sync implication at all**.

1. Copy `.github/standards/`, `.github/skills/`, `.github/agents/`, `.github/prompts/` and
   `.github/copilot-instructions.md` into your existing repo.
2. Work through [07 — Make it yours](07-make-it-yours.md). Replace the naming conventions and the
   glossary with yours **before** anyone reads them, or the first impression is "these aren't ours."
3. Run `scripts/validate-structure.ps1` in report-only mode to see what your current repo would fail.
   Do not turn it into a blocking CI gate yet — see below.
4. Install the Fabric skills: `scripts/bootstrap-skills.ps1`.

Write down what your current practice actually is before replacing it. A standard that contradicts
what the team already does, with no acknowledgement, gets ignored — and you lose the chance to find
out that the existing way was better.

### Turn on enforcement last

Point the validator at a brownfield repo and it will produce a large number of findings, most of
which are pre-existing. Adding a blocking gate on day one means the first ten PRs fail for reasons
unrelated to their content, and the team learns that the gate is noise.

Run it in report-only mode first. Fix the class of finding you care about. Then make it blocking.

## Decision 2 — move the directories

Only worth doing if you have several workspaces and no convention for where they live. It requires a
disconnect and reconnect, and there is one property of reconnecting that determines the whole
procedure:

> "When you reconnect, it overwrites all items in the workspace or branch and not just the conflicted
> ones."
> — [Basic concepts in Git integration](https://learn.microsoft.com/fabric/cicd/git-integration/git-integration-process)

Reconnect is **not a merge**. It is a direction choice with an overwrite. Everything below follows
from making sure the side you overwrite *from* is the correct one.

The link itself survives a move: the `logicalId` in each `.platform` file
[preserves the link "even if the name or directory change"](https://learn.microsoft.com/fabric/cicd/git-integration/source-code-format).
The files carry their own identity, so relocating a directory is not the same as recreating items.

### The procedure

1. **Pilot on a throwaway workspace first.** Not the dev workspace of a real project — a scratch one.
   You are verifying that items re-link rather than duplicate, in *your* tenant, on *your* item types.
2. **Commit everything from Fabric.** The workspace must have zero pending changes. This is what
   makes Git authoritative, which is what makes step 5 safe.
3. **Move the directory in Git** with `git mv`, so history follows. Open it as a normal PR.
4. **Disconnect** the workspace (workspace admin only).
5. **Reconnect** to the new directory, choosing the **Git → workspace** direction.
6. **Verify item-by-item** that the workspace has the same items with the same IDs — not copies.

If branch policy stops you committing to the target branch directly, Microsoft recommends the
[Checkout Branch](https://learn.microsoft.com/fabric/cicd/git-integration/conflict-resolution) route:
branch from the workspace state, commit there, then PR it back.

### Two things that bite

- **Workspace folders count as structure.** If your workspace uses folders and the Git directory has
  no subfolders, Fabric treats that as a difference and you get *uncommitted changes* on connect.
  Commit before you update, or the Git structure overwrites the workspace structure.
- **Do it per workspace, never in bulk.** One at a time, verified, is slower and much cheaper than
  discovering a systematic problem across twelve workspaces at once.

## Decision 3 — repo topology

There is no universally right answer, and this repo's layout is not a claim that one repo is always
correct.

| Shape | Choose it when |
|---|---|
| **One repo, many workspaces** (this repo) | One team or one trust boundary; you want the shared core in one place |
| **Repo per domain** | Separate teams, separate release cadence, or teams that must not see each other's work |

A repo is a **permission boundary** first and an organisational unit second. Start from "who must not
have write access to what" and the answer usually falls out.

### If you keep multiple repos, install the shared core — don't copy it

This is the same problem as the Fabric skills, one level in. A shared core copied into five repos is
five divergent shared cores within a quarter, and no one will notice until two of them contradict
each other in a review.

Give it one home and consume it:

- **Git submodule** — precise, but everyone must know the submodule commands
- **Published package** (npm/NuGet/PyPI) — cleanest, needs a release process
- **A sync pipeline** that opens a PR into each consumer repo when the core changes — least elegant,
  fewest prerequisites, works fine in Azure DevOps

Whichever you choose, the rule is the one from
[`.github/skills/README.md`](../.github/skills/README.md): the layer somebody else maintains gets
*installed*, and the layer you maintain gets *authored*.

## A sequencing that works

| When | Do | Why this order |
|---|---|---|
| Week 1 | Shared core into **one** repo. Standards and glossary rewritten to match reality. | Immediate, reversible, no Fabric risk |
| Week 2 | Install the Fabric skills. Write `project-context.md` for one real project. | This is where agent quality actually comes from |
| Week 3–4 | Validator in report-only mode. PR template on. Fix one class of finding. | Visible improvement without a blocking gate |
| Month 2 | Pilot the directory move on a scratch workspace, then one real dev workspace. | Proves the procedure before it matters |
| Month 2–3 | Decide repo topology deliberately. Set up the install mechanism if multiple repos. | By now you know what the boundaries actually are |
| Ongoing | ADRs from here on. Don't backfill them. | Backfilled ADRs are fiction; ADRs are for decisions you are making now |

Deliberately not on the list: retrofitting names onto existing live items. It is the most expensive
change available and the least valuable. Apply the naming convention to everything **new**, and let
the old names age out.

## What "done" looks like

You have adopted this successfully when:

- A new joiner can find the naming convention without asking anyone
- Copilot answers a Fabric question correctly *and* answers a "how do we do this here" question correctly
- Two reviewers check the same things
- Somebody can explain why a two-year-old decision was made, from the repo

None of those require the directory layout. That is the point.

## Related

- [07 — Make it yours](07-make-it-yours.md) — what to replace once you've adopted it
- [02 — Connect a workspace](02-connect-a-workspace.md) — the connect procedure in detail
- [06 — Azure DevOps port](06-azure-devops-port.md) — if your existing setup lives in Azure DevOps
- [`../.github/skills/README.md`](../.github/skills/README.md) — install vs. author, the pattern reused above
