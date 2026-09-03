---
mode: agent
description: Add a new Fabric workspace to this repository and walk me through connecting it to Git.
---

# New Workspace

Follow [`../skills/workspace-bootstrap/SKILL.md`](../skills/workspace-bootstrap/SKILL.md).

## Ask me first

1. Which **project**? (existing folder under `projects/`, or a new one)
2. Which **domain and stage**? (e.g. sales / dev)
3. Which **promotion pattern** does this project use — Fabric deployment pipelines, or branch per
   stage? If the project already exists, read its `decisions/` folder instead of asking.

Do not create anything until I have confirmed the proposed workspace name and directory path.

## Then

1. Propose the workspace name and repo directory from
   [`../standards/naming-conventions.md`](../standards/naming-conventions.md). Wait for confirmation.
2. Create the repo side: the workspace directory, the workspace notes file next to it, a row in
   `projects/<project>/workspaces/README.md`, and — for a new project — a filled-in copy of
   `projects/_template/`.
3. Commit with `feat: add <workspace-name> workspace scaffold` and remind me to push.
4. Print the Fabric-side click-path for me to do myself, including the exact Git folder path to paste.
5. Print the verification checklist.

## Output

- A summary of the files created
- The exact Git folder path, in a copyable code block
- The numbered Fabric steps
- The verification checklist as a checkbox list
