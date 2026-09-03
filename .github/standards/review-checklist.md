# Review Checklist

What a reviewer actually looks at. Ten minutes, not an hour.

Reviewing Fabric content in Git is different from reviewing application code: much of the diff is
machine-generated and unreadable. **Don't pretend to read generated JSON.** Review the things a
human can actually judge, and let automation handle the rest.

## Before you open the diff

- [ ] **Is the PR description a sentence a stakeholder would understand?**
      "Adds returns to the sales model" — not "update SM_Sales".
- [ ] **Does the branch name match the convention?** `feature/<initials>-<description>`.
- [ ] **Did CI pass?** If validation is red, stop. Don't review a broken change.

## The diff

- [ ] **Only expected item folders changed.** Fabric commits are chatty — an unexpected item in the
      diff usually means someone edited the wrong workspace.
- [ ] **No `.platform` file has a changed `logicalId` or `type`.** Usually the tell for a copy-pasted
      item folder. It breaks the workspace link. Automation flags it; you confirm it.
- [ ] **No item directory was renamed in Git** — it stops the name syncing and breaks dependency
      paths in other items. Rename in the workspace instead.
- [ ] **No secrets.** Connection strings, keys, SAS tokens, personal email addresses, tenant GUIDs
      that shouldn't be public.
- [ ] **No hard-coded stage-specific values** outside the parameter file — workspace IDs, capacity
      IDs, lakehouse GUIDs, environment URLs.
- [ ] **Names follow [`naming-conventions.md`](naming-conventions.md).**

## The substance

- [ ] **Is this in the right layer?** Bronze transformations that belong in silver are the most common
      structural mistake and the most expensive to unpick later.
- [ ] **Does it duplicate something that already exists?** A new `NB_Sales_Load_Customers` next to an
      existing `NB_Sales_Bronze_Ingest` is a smell.
- [ ] **Semantic model changes:** are measures documented, is the storage mode deliberate, do
      relationships have the intended cross-filter direction?
- [ ] **Notebooks:** parameterised (no hard-coded paths), idempotent (safe to re-run), and they fail
      loudly rather than swallowing errors.
- [ ] **Is there a decision here?** If the answer to "why did you do it that way" is interesting,
      it belongs in `projects/<project>/decisions/` — as part of this PR.

## Documentation

- [ ] The relevant `README.md` index was updated **in this PR**, not "later".
- [ ] If a standard changed, everything it affects changed too.

## Approving

Approve when you'd be comfortable being paged about it. If the diff is unreadable and the description
doesn't tell you what it does, that's a request for changes — not a reason to approve and hope.

## Related

- [`naming-conventions.md`](naming-conventions.md)
- [`security-and-access.md`](security-and-access.md)
- [`../../scripts/validate-structure.ps1`](../../scripts/validate-structure.ps1) — automates the mechanical checks
- [`../prompts/review-fabric-pr.prompt.md`](../prompts/review-fabric-pr.prompt.md) — run this checklist with an agent
