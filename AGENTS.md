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

1. **Never edit files inside a Git-connected workspace directory by hand.** Those directories
   (`projects/*/workspaces/*/`) are owned by Fabric. Hand-editing `.platform` files — especially
   `logicalId` — breaks the workspace↔Git link. Change items in Fabric, then commit.
2. **Never write to a production workspace.** Promotion happens through the release process only.
3. **Follow [`.github/standards/naming-conventions.md`](.github/standards/naming-conventions.md).**
   If a name is not covered there, propose an addition to the standard rather than inventing one.
4. **Read the project's `project-context.md`** before doing anything in `projects/<project>/`.
5. **Cite sources for platform behaviour.** Fabric changes monthly. Link Microsoft Learn rather
   than asserting from memory.
