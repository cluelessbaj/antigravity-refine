---
name: refine
description: Intercepts rough task descriptions (/refine <prompt> or refine: <prompt>), inspects the repository context (file structure, languages, existing test runners, git status), and outputs a hardened, project-specific Antigravity execution contract before any code modifications begin.
---

# /refine — Context-Aware Task Refinement Skill

## Overview
The `/refine` skill intercepts ambiguous or rough task requests, grounds them in the concrete reality of the current workspace, and generates a deterministic, project-specific execution contract. It acts as a pre-execution safety gate to ensure zero premature code modifications occur.

## Triggers
Activate this skill whenever user input starts with:
- `/refine <prompt>`
- `refine: <prompt>`

---

## Mandatory Execution Workflow

When `/refine` is invoked, **DO NOT** execute any code edits or file modifications immediately. Follow this strict three-step workflow:

### Step 1: Context Inspection
Perform targeted inspection of the workspace to ground the request in actual files:
1. **Target File Identification:**
   - Scan the codebase using search tools (`find_by_name`, `grep_search`, `list_dir`, and `view_file`).
   - Locate the exact files, modules, and directories directly relevant to the user's rough goal.
   - Resolve real filesystem paths rather than generic or hypothetical names.
2. **Tooling & Test Gate Discovery:**
   - Detect active build tools, task runners, and test frameworks in the project:
     - Go: `go test ./...`, `go build -o /dev/null`
     - Node / JS / TS: `npm test`, `yarn test`, `pnpm test`, `npm run lint`, `package.json` scripts
     - Python: `pytest`, `python3 -m unittest`, `python3 -m py_compile`, `ruff`, `flake8`
     - Rust: `cargo test`, `cargo check`
     - Make / C / C++: `make test`, `make check`, `Makefile`
   - Identify the exact command that must exit code 0 to certify completion.
3. **Repository State & Constraints:**
   - Run `git status` or inspect directory status to check for uncommitted changes or read-only files.
   - Note critical dependencies, configs, lockfiles, and unrelated modules that must remain untouched.

---

### Step 2: Draft the Hardened Contract
Format and output the deterministic specification using this exact Markdown template:

```markdown
## Refined Task Contract: [Concise Feature/Fix Name]

- **Target End-State:** [Measurable deliverable tailored to this repo]
- **Target Files:**
  - Modify: `[explicit paths to existing files]`
  - Create: `[explicit paths if new files are needed]`
  - Read-Only / Untouchable: `[configs, locks, dependencies, unrelated modules]`
- **Tooling & Test Gate:**
  - Verification command: `[exact test/lint command found in the project]`
  - Expected result: Exit code 0, 0 test failures.
- **Pre-flight Dependencies:** [Required environment variables, services, or ports]
```

---

### Step 3: Awaiting Confirmation
1. Print the refined contract directly in the conversation.
2. Output the exact confirmation prompt:
   > "Would you like me to proceed with executing this specification?"
3. **STOP** and wait for explicit confirmation from the user (e.g., `yes`, `run`, `proceed`).
4. **DO NOT** perform any file writes, edits, deletions, or destructive commands until explicit confirmation is received.
