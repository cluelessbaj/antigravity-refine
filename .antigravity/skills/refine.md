---
name: refine
description: Intercepts rough task descriptions (/refine <prompt> or refine: <prompt>), inspects repository context, drafts a hardened contract, generates an interactive implementation plan for user review, and executes only after explicit continuation approval.
---

# /refine — Context-Aware Task Refinement & Planning Skill

## Overview
The `/refine` skill intercepts ambiguous or rough task requests, grounds them in the concrete reality of the current workspace, and generates a deterministic, project-specific execution contract followed by an interactive **Implementation Plan**. It acts as a multi-stage safety gate to ensure zero premature code modifications occur.

## Triggers
Activate this skill whenever user input starts with:
- `/refine <prompt>`
- `refine: <prompt>`

---

## Mandatory Execution Workflow

When `/refine` is invoked, **DO NOT** execute any code edits or file modifications immediately. Follow this strict three-stage workflow:

### Stage 1: Contract Refinement & Pre-Execution Hold
1. **Pre-Execution Hold:**
   - Strictly prohibit any immediate code modifications, file creation, or destructive terminal commands.
2. **Context Inspection:**
   - Scan the codebase using `find_by_name`, `grep_search`, `list_dir`, and `view_file`.
   - Locate the exact files, modules, and directories directly relevant to the user's rough goal.
   - Detect active build tools, package scripts, and test runners (e.g., `go test ./...`, `pytest`, `npm test`, `cargo test`, `Makefile`).
   - Check git status (`git status -s`) and identify untouchable files (locks, configs, unrelated code).
3. **Draft Hardened Contract:**
   Output the deterministic specification matching this exact structure:

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

4. **Awaiting Contract Approval:**
   - Prompt: `"Would you like me to generate the implementation plan for this specification?"`
   - Halt execution and await explicit user confirmation (`yes`, `run`, `proceed`).

---

### Stage 2: Interactive Planning Phase
Once the user confirms the contract:
1. **Create Implementation Plan Artifact:**
   - Write or update `implementation_plan.md` in the artifact directory (`UserFacing: true`, `RequestFeedback: true`).
   - Structure the plan with:
     - **Goal Description**: Clear summary of what will be accomplished.
     - **User Review Required**: Any critical design decisions or breaking changes.
     - **Proposed Changes**: Ordered components, file-by-file breakdown (`[MODIFY]`, `[NEW]`, `[DELETE]`) with exact paths.
     - **Verification Plan**: Automated test commands and manual verification steps.
2. **User Inspection & Edits:**
   - Direct the user to review the generated implementation plan artifact.
   - The user can review, critique, or suggest edits to the plan.
   - Output: `"Please review the implementation plan. Reply with 'continue' or 'proceed' to execute, or describe any changes you would like to make."`
   - **DO NOT** modify any source code during this stage.

---

### Stage 3: Bounded Plan Execution & Verification
Only when the user provides explicit continuation approval (`continue`, `proceed`, `run`, `execute`):
1. **Execute Changes:**
   - Perform code modifications strictly bounded by the approved implementation plan.
2. **Run Test Gate:**
   - Execute the verification command defined in the contract.
   - Ensure exit code 0 and zero test failures.
3. **Create Walkthrough Artifact:**
   - Document all changes, test commands run, and validation results in `walkthrough.md`.
