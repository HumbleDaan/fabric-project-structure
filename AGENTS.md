# AGENTS.md

Entry point for AI coding agents working in this repository.

This file exists so that any agent host picks up the same rules. The substance lives in
[`.github/copilot-instructions.md`](.github/copilot-instructions.md) — **read that file next.**

| Host | Reads |
|---|---|
| GitHub Copilot (VS Code, CLI) | `.github/copilot-instructions.md` |
| Codex / Jules / OpenCode / Copilot CLI | `AGENTS.md` (this file) |
| Claude Code | `CLAUDE.md` |

All three point at the same place. Keep it that way — one source of truth, thin pointers.

## Non-negotiables

1. **Never change the identity layer of a Fabric item.** In `projects/*/workspaces/*/`, the
   `logicalId` and `type` in `.platform`, and the item folder name, are what link the files to the
   live workspace. Editing item *definitions* (TMDL, notebook `.py`, warehouse SQL) is supported and
   often recommended — but sync **one direction at a time**. Detail in
   [`.github/copilot-instructions.md`](.github/copilot-instructions.md).
2. **Never write to a production workspace.** Promotion happens through the release process only.
3. **Follow [`.github/standards/naming-conventions.md`](.github/standards/naming-conventions.md).**
   If a name is not covered there, propose an addition to the standard rather than inventing one.
4. **Read the project's `project-context.md`** before doing anything in `projects/<project>/`.
5. **Cite sources for platform behaviour.** Fabric changes monthly. Link Microsoft Learn rather
   than asserting from memory.
